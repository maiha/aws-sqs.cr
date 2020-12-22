# ```console
# $ jq '.shapes[].type' api-2.json | sort | uniq -c
# 1 "blob"
# 1 "boolean"
# 2 "integer"
# 16 "list"
# 5 "map"
# 8 "string"
# 57 "structure"
# ```

require "file_utils"
require "json"
require "log"

NAME2SHAPE = Hash(String, Codegen::Shape).new
OUTPUT_TYPE_NAMES = Hash(String, String).new

CRYSTAL_TYPE_MAPPING = {
  "BoxedInteger" => "Int32",
}
DEFAULT_OUTPUT_TYPE = "DefaultResult"

def resolve_type(name : String) : String
  if type = CRYSTAL_TYPE_MAPPING[name]?
    return type
  end

  if shape = NAME2SHAPE[name]?
    case shape
    when .is_enum?
      return name
    when Codegen::NativeType
      return shape.native_type
    end
  end
  return name
end

# {"shape" => "AddPermissionRequest"}
def resolve_type(hash : Hash(String, String)) : String
  name = hash["shape"]? || raise "BUG: resolve_type is called without shape. [#{hash.inspect}]"
  resolve_type(name)
end

def resolve_type(name) : String
  raise "BUG: resolve_type is called without String. [#{name.inspect}]"
end

class Codegen
  module NativeType
    macro included
      def native_type : String
        NATIVE_TYPE
      end
    end
  end
  
  #  "metadata":{
  #    "apiVersion":"2012-11-05",
  #    "serviceId":"SQS",
  class Root
    include JSON::Serializable
    property metadata : Hash(String, String)
    property operations : Hash(String, Operation)
    property shapes : Hash(String, Shape)
  end

  #     "ReceiveMessage":{
  #       "name":"ReceiveMessage",
  #       "http":{
  #         "method":"POST",
  #         "requestUri":"/"
  #       },
  #       "input":{"shape":"ReceiveMessageRequest"},
  #       "output":{
  #         "shape":"ReceiveMessageResult",
  #         "resultWrapper":"ReceiveMessageResult"
  #       },
  #       "errors":[
  #         {"shape":"OverLimit"}
  #       ]
  class Operation
    include JSON::Serializable
    property name   : String
    property http   : Hash(String, String | Int64)
    property input  : Hash(String, String)
    property output : Hash(String, String)?
  end

  class Field
    getter param_key
    getter name
    getter type
    getter required
    getter flattend

    def initialize(@param_key : String, @name : String, @type : String, @required : Bool, @flattened : Bool)
    end

    def to_method_arg : String
      if required
        "%s : %s" % [name, type]
      else
        "%s : %s? = nil" % [name, type]
      end
    end
  end
  
  #   "ActionNameList": {
  #     "type": "list",
  #
  #   "SendMessageRequest": {
  #     "type": "structure",
  #     "required": [
  #       "QueueUrl",
  #       "MessageBody"
  #     ],
  #     "members": {
  #       "QueueUrl": {
  #         "shape": "String"
  #       },

  class Shape
    include JSON::Serializable
    use_json_discriminator "type", {
      blob: ShapeBlob,
      boolean: ShapeBoolean,
      double: ShapeDouble,
      float: ShapeFloat,
      integer: ShapeInteger,
      long: ShapeLong,
      string: ShapeString,
      timestamp: ShapeTimestamp,
      map: ShapeMap,
      list: ShapeList,
      structure: ShapeStructure,
    }
    property type : String
    property flattened : Bool?
    
    include Enumerable(Field)

    def each(&block : Field -> _)
      nil
    end

    def is_enum? : Bool
      false
    end
  end

  class ShapeBlob < Shape
  end

  class ShapeBoolean < Shape
    include NativeType
    NATIVE_TYPE = "Bool"
  end

  class ShapeDouble < Shape
    include NativeType
    NATIVE_TYPE = "Float64"
  end

  class ShapeFloat < Shape
    include NativeType
    NATIVE_TYPE = "Float32"
  end

  class ShapeInteger < Shape
    include NativeType
    NATIVE_TYPE = "Int32"
  end

  class ShapeLong < Shape
    include NativeType
    NATIVE_TYPE = "Int64"
  end

  class ShapeString < Shape
    include NativeType
    NATIVE_TYPE = "String"

    # "enum": [
    #   "AWSTraceHeader"
    # ]
    @[JSON::Field(key: "enum")]
    property _enum : Array(String)?

    def is_enum? : Bool
      !! _enum
    end

    def each(&block : Field -> _)
      if array = _enum
        array.each do |v|
          field = Field.new(
            param_key: v,
            name: v,
            type: "String",
            required: true,
            flattened: !!flattened,
          )
          yield field
        end
      else
        field = Field.new(
          param_key: "unknown",
          name: "unknown",
          type: "String",
          required: true,
          flattened: !!flattened,
        )
      end
    end
  end

  class ShapeTimestamp < Shape
    include NativeType
    NATIVE_TYPE = "Time"
  end

  class ShapeMap < Shape
    #      "type": "map",
    #      "key": {
    #        "shape": "String",
    #        "locationName": "Name"
    #      },
    #      "value": {
    #        "shape": "MessageAttributeValue",
    #        "locationName": "Value"
    #      },
    #      "flattened": true
    #    },
    property key : Hash(String, String)
    property value : Hash(String, String)
  end

  class ShapeList < Shape
    #   "AttributeNameList": {
    #     "type": "list",
    #     "member": {
    #       "shape": "QueueAttributeName",
    #       "locationName": "AttributeName"
    #     },
    #     "flattened": true

    # Or, the case of missing locationName
    #     "member": {
    #       "shape": "action",
    #     },

    property member : Hash(String, String)
    #      property flattended : Bool

    def each(&block : Field -> _)
      hash = member
      name = hash["locationName"]? || hash["shape"]? || raise ArgumentError.new("locationName is missing: hash=#{hash.inspect}")
      type = resolve_type(hash["shape"])
      field = Field.new(
        param_key: name,
        name: name.underscore,
        type: type,
        required: true,
        flattened: !!flattened,
      )
      yield field
    end
  end

  class ShapeStructure < Shape
    #     "type": "structure",
    #     "required": [
    #       "QueueUrl",
    #       "MessageBody"
    #     ],
    #     "members": {
    #       "QueueUrl": {
    #         "shape": "String"
    #       },
    property required : Array(String)?
    property members  : Hash(String, Hash(String, String | Bool))

    # @members=
    #  {"QueueUrl" => {"shape" => "String"},
    #   "MessageBody" => {"shape" => "String"},
    #   "DelaySeconds" => {"shape" => "Integer"},
    #   "MessageAttributes" =>
    #    {"shape" => "MessageBodyAttributeMap",
    #     "locationName" => "MessageAttribute"},
    #   "MessageSystemAttributes" =>
    #    {"shape" => "MessageBodySystemAttributeMap",
    #     "locationName" => "MessageSystemAttribute"},
    #   "MessageDeduplicationId" => {"shape" => "String"},
    #   "MessageGroupId" => {"shape" => "String"}},
    # @required=["QueueUrl", "MessageBody"],
    # @type="structure">

    def each(&block : Field -> _)
      members.each do |name, hash|
        type = resolve_type(hash["shape"])
        case type
        when String
          field = Field.new(
            param_key: name,
            name: name.underscore,
            type: type,
            required: !!required.try(&.includes?(name)),
            flattened: !!flattened,
          )
          yield field
        else
          raise ArgumentError.new("shape is #{type.class}: name=[#{name}], hash=#{hash.inspect}")
        end
      end
    end
  end

  def self.inspect(root : Root)
    puts "operations: %d" % root.operations.size
    puts "shapes: %d" % root.shapes.size

    puts "--- operations ------------------------------------------------------------"
    root.operations.each_with_index do |(name, op), i|
      p op.input
    end

    puts "--- shapes ------------------------------------------------------------"
    shown_types = Set(String).new
    root.shapes.each_with_index do |(name, shape)|
      shape.type
      next if showntypes.includes?(shape.type)
      shown_types << shape.type
      p shape
    end
  end

  ######################################################################
  ### main
  
  property root   : Root
  property shapes : Hash(String, Shape)
  property api_version : String
  property service_id : String

  delegate operations, shapes, to: root

  def initialize(@service_name : String, @json_path : String, @output_dir : String)
    @root   = Root.from_json(File.read(@json_path))
    @shapes = @root.shapes
    @native_types = Hash(String, String).new
    @service_id = (@root.metadata["serviceId"]? || @service_name.capitalize).gsub(/\s+/, "")
    @api_version = @root.metadata["apiVersion"] # "apiVersion":"2012-11-05",

    # register shape maps in constant for global accesss
    NAME2SHAPE.merge!(shapes)

    # register output type names
    operations.each do |name, op|
      if name = op.output.try{|hash| hash["shape"]?}
        OUTPUT_TYPE_NAMES[name] = name
      end
    end
  end

  def generate
    # Delete auto generated files.
    FileUtils.rm_rf(@output_dir)
    FileUtils.mkdir_p(@output_dir)

    # generate types.cr
    Dir.cd(@output_dir) do
      File.write("api.cr", build_code_api)
      Log.info { "Created api.cr" }

      File.write("types.cr", build_code_types)
      Log.info { "Created types.cr" }
    end
  end

  private def ignore_type?(name)
    return true if CRYSTAL_TYPE_MAPPING[name]?
    return true if name =~ /^[a-z]/
    return true if %( String ).includes?(name)
    return false
  end

  private def do_not_edit_message
    <<-EOF
      # Generated by #{File.basename(__FILE__)}
      #     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
      EOF
  end

  private def build_code_types : String
    data = String.build do |s|
      s.puts do_not_edit_message
      s.puts
      s.puts %Q|module Aws::#{@service_id}|
      s.puts %Q|  class Response(I, R)|
      s.puts %Q|    getter input : I|
      s.puts %Q|    getter response : HTTP::Client::Response|
      s.puts %Q|    delegate status, body, to: @http_response|
      s.puts
      s.puts %Q|    def initialize(@input, @response)|
      s.puts %Q|    end|
      s.puts %Q|  end|
      s.puts %Q|end|
      s.puts

      s.puts %Q|module Aws::#{@service_id}::Types|

      s.puts %Q|  module Input|
      s.puts %Q|    abstract def set_params(params : HTTP::Params, serializer)|
      s.puts %Q|  end|
      s.puts
      
      s.puts %Q|  module InputList|
      s.puts %Q|  end|
      s.puts

      s.puts %Q|  module Output|
      s.puts %Q|  end|
      s.puts

      Log.debug { "iterate shapes: #{shapes.size}" }
      shapes.each do |name, shape|
        clue = "process shape(#{name}, #{shape.class}) (enum:#{shape.is_enum?}, list:#{shape.is_a?(ShapeList)})"
        Log.debug { clue }
        next if ignore_type?(name)

        begin
          case shape
          when.is_enum?
            gen_type_enum(s, name, shape)
          when ShapeList
            gen_type_list(s, name, shape)
          else
            gen_type_default(s, name, shape)
          end
          s.puts
        rescue err
          Log.fatal { "#{clue}: #{err}" }
          raise err
        end
      end

      operations.each do |name, op|
        input_shape_name = resolve_type(op.input)
        response_type    = input_shape_name.sub(/Request$/, "") + "Response"

        s.puts %Q|  class #{response_type}(I, R) < Response(I, R)|
        s.puts %Q|  end|
      end

      s.puts %Q|end|
    end
  end

  private def gen_type_enum(s, name, shape)
    s.puts   %Q|  enum #{name}|
    shape.each do |f|
      s.puts %Q|    #{f.name}|
    end
    s.puts   %Q|  end|
    s.puts
  end

  private def gen_type_list(s, name, shape)
    shape.each do |f|
      # f: @param_key="AttributeName", @name="attribute_name", @type="QueueAttributeName", @required=true
      # ```
      # attribute_names : Array(QueueAttributeName)
      # ```
      nullable = f.required ? "" : "?"
      s.puts %Q|  record #{name},|
      s.puts %Q|    list : Array(#{f.type})#{nullable} do|
      s.puts
      s.puts %Q|    include Input|
      s.puts %Q|    include InputList|
      s.puts
      s.puts %Q|    def set_params(params : HTTP::Params, serializer)|
      s.puts %Q[      list.try{|_list| _list.each_with_index do |v, i|]
      s.puts %Q|        serializer.set_params(params, serializer, name: "#{f.param_key}.\#{i+1}", value: v)|
      s.puts %Q|      end}|
      s.puts %Q|    end|
      s.puts %Q|  end|
    end
  end

  private def gen_type_default(s, name, shape)
    return if name =~ /^[a-z]/

    s.print %Q|  record #{name}|
    if shape.any?
      name_maxlen = shape.map(&.name.size).max
      shape.each do |f|
        # ```
        # queue_url       : String,
        # attribute_names : AttributeNameList?,
        # ```
        fixed_name = f.name.ljust(name_maxlen)
        nullable = f.required ? "" : "?"
        s.print %Q|,\n    #{fixed_name} : #{f.type}#{nullable}|
      end
    end

    if OUTPUT_TYPE_NAMES[name]?
      s.puts     %Q|  do|
      s.puts
      s.puts     %Q|    include Output|
      s.puts     %Q|  end|
    
    elsif name.ends_with?("Request")
      s.puts     %Q|  do|
      s.puts
      s.puts     %Q|    include Input|
      s.puts     %Q|    include InputList| if name.ends_with?("List")
      s.puts
      s.puts     %Q|    def set_params(params : HTTP::Params, serializer)|
      shape.each do |f|
        s.puts   %Q|      serializer.set_params(params, serializer, name: "#{f.param_key}", value: #{f.name}) if !#{f.name}.nil?|
      end
      s.puts     %Q|    end|
      s.puts     %Q|  end|
    else
      s.puts
    end
  end

  private def build_code_api : String
    String.build do |s|
      s.puts do_not_edit_message
      s.puts
      s.puts %Q|require "./types"|
      s.puts
      s.puts %Q|module Aws::#{@service_id}::API|
      s.puts %Q|  include Types|
      s.puts

      operations.each do |name, op|
        Log.info { "gen_api: operations[#{name}], op=[#{op.inspect}]" }

        method_name = op.name.underscore
        http_method = op.http["method"].to_s.upcase
        request_uri = op.http["requestUri"]

        input_type    = resolve_type(op.input)
        input_shape   = shapes[input_type]? || raise ArgumentError.new("no shapes [ #{input_type}]")
        method_arg    = input_shape.map(&.to_method_arg).join(", ")
        output_type   = op.output.try{|hash| hash["shape"]?} || DEFAULT_OUTPUT_TYPE
        response_type = input_type.sub(/Request$/, "") + "Response"

        case http_method
        when "POST", "PUT"
          headers = %Q|{"Content-Type" => "application/x-www-form-urlencoded"}|
        else
          headers = "nil"
        end
        
        s.puts %Q|  def #{method_name}(#{method_arg})|
        s.puts %Q|    input = #{input_type}.new(|
        input_shape.each do |a|
          s.puts %Q|      #{a.name}: #{a.name},|
        end
        s.puts %Q|    )|
        s.puts %Q|    params   = build_params(action: "#{name}", version: "#{api_version}", input: input)|
        s.puts %Q|    request  = build_request("#{http_method}", "#{request_uri}", headers: #{headers}, params: params)|
        s.puts %Q|    response = execute(request, input, output: #{output_type})|
        s.puts %Q|    #{response_type}(#{input_type}, #{output_type}).new(input, response)|
        s.puts %Q|  end|
        s.puts
      end

      s.puts %Q|end|
    end
  end
end

######################################################################
### codegen <SERVICE_NAME> <API_DIR> <OUTPUT_DIR>
### codegen "sqs" gen/aws-sdk-go/models/apis" "gen/src"

service_name = ARGV.shift? || raise ArgumentError.new("arg1: missing <SERVICE_NAME>")
api_dir      = ARGV.shift? || raise ArgumentError.new("arg2: missing <API_DIR>")
output_dir   = ARGV.shift? || raise ArgumentError.new("arg3: missing <OUTPUT_DIR>")
json_path    = `find #{api_dir}/ -name 'api*.json' | tail -1`.chomp
# gen/aws-sdk-go/models/apis/sqs/2012-11-05/api-2.json

Log.setup do |c|
  # level = ENV["DEBUG"]? ? Log::Severity::Debug : Log::Severity::Info
  level = Log::Severity::Debug
  c.bind "*", level, Log::IOBackend.new
end

gen = Codegen.new(service_name: service_name, json_path: json_path, output_dir: output_dir)
gen.generate
