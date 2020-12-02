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

require "json"

SHAPE_NATIVE_MAPPING = {
  "Integer" => "Int32",
}
private def extract_shape(hash)
  shape = hash["shape"] || raise ArgumentError.new("shape is missing: hash=#{hash.inspect}")
  return SHAPE_NATIVE_MAPPING[shape]? || shape
end

class GenCode
  class Root
    include JSON::Serializable
    property metadata : Hash(String, String)
    property operations : Hash(String, Operation)
    property shapes : Hash(String, Shape)
  end

  #     "AddPermission": {
  #       "name": "AddPermission",
  #       "http": {
  #         "method": "POST",
  #         "requestUri": "/"
  #       },
  #       "input": {
  #         "shape": "AddPermissionRequest"
  #       },
  #       "errors": [
  #         {
  #           "shape": "OverLimit"
  #         }
  #       ]
  #     },
  class Operation
    include JSON::Serializable
    property name : String
    property http : Hash(String, String | Int64)
    property input : Hash(String, String)
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
      integer: ShapeInteger,
      string: ShapeString,
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
  end

  class ShapeInteger < Shape
  end

  class ShapeString < Shape
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
    property member : Hash(String, String)
    #      property flattended : Bool

    def each(&block : Field -> _)
      hash = member
      name = hash["locationName"] || raise ArgumentError.new("locationName is missing: hash=#{hash.inspect}")
      type = extract_shape(hash)
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
        type = extract_shape(hash)
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

  def self.build(root : Root)
    shapes = root.shapes
    root.operations.each do |name, op|
      puts build_method_definition(op, shapes)
      puts
    end
  end

  ######################################################################
  ### main
  
  property root   : Root
  property shapes : Hash(String, Shape)
  property api_version : String

  delegate operations, shapes, to: root

  def initialize(@service_name : String, @json_path : String)
    @root   = Root.from_json(File.read(@json_path))
    @shapes = @root.shapes

    # json_path: "aws-sdk-go/models/apis/sqs/2012-11-05/api-2.json"
    case @json_path
    when %r{/#{@service_name}/(\d{4}-\d{2}-\d{2})/}
      @api_version = $1
    else
      raise ArgumentError.new("The json_path doesn't contain VERSION string. [#{@json_path}]")
    end
  end

  private def ignore_type?(name)
    %( String ).includes?(name)
  end

  private def do_not_edit_message
    <<-EOF
      # Generated by #{File.basename(__FILE__)}
      #     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN
      EOF
  end

  def gen_types
    path = "src/aws-#{@service_name}/types.cr"

    data = String.build do |s|
      s.puts do_not_edit_message
      s.puts
      s.puts %Q|module Aws::#{@service_name.upcase}::Types|

      s.puts %Q|  module Input|
      s.puts %Q|    abstract def set_params(params : HTTP::Params, serializer)|
      s.puts %Q|  end|
      s.puts
      
      s.puts %Q|  module InputList|
      s.puts %Q|  end|
      s.puts
      
      shapes.each do |name, shape|
        next if ignore_type?(name)

        case shape
        when.is_enum?
          gen_type_enum(s, name, shape)
        when ShapeList
          gen_type_list(s, name, shape)
        else
          gen_type_default(s, name, shape)
        end
        s.puts
      end
      s.puts %Q|end|
    end

    File.write(path, data)
    puts "Created #{path}"
  end

  def gen_type_enum(s, name, shape)
    s.puts   %Q|  enum #{name}|
    shape.each do |f|
      s.puts %Q|    #{f.name}|
    end
    s.puts   %Q|  end|
    s.puts
  end

  def gen_type_list(s, name, shape)
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

  def gen_type_default(s, name, shape)
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

    if name.ends_with?("Request")
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

  def gen_api
    path = "src/aws-#{@service_name}/api.cr"

    data = String.build do |s|
      s.puts do_not_edit_message
      s.puts
      s.puts %Q|require "./types"|
      s.puts
      s.puts %Q|module Aws::#{@service_name.upcase}::API|
      s.puts %Q|  include Types|
      s.puts

      operations.each do |name, op|
        method_name = op.name.underscore
        http_method = op.http["method"].to_s.upcase
        request_uri = op.http["requestUri"]

        input_shape_name = extract_shape(op.input)
        input_shape = shapes[input_shape_name]? || raise ArgumentError.new("no shapes [#{input_shape_name}]")
        method_arg  = input_shape.map(&.to_method_arg).join(", ")

        case http_method
        when "POST", "PUT"
          headers = %Q|{"Content-Type" => "application/x-www-form-urlencoded"}|
        else
          headers = "nil"
        end
        
        s.puts %Q|  def #{method_name}(#{method_arg})|
        s.puts %Q|    input = #{input_shape_name}.new(|
        input_shape.each do |a|
          s.puts %Q|      #{a.name}: #{a.name},|
        end
        s.puts %Q|    )|
        s.puts %Q|    params  = build_params(action: "#{name}", version: "#{api_version}", input: input)|
        s.puts %Q|    request = build_request("#{http_method}", "#{request_uri}", headers: #{headers}, params: params)|
        s.puts %Q|    execute(request, input)|
        s.puts %Q|  end|
        s.puts
      end

      s.puts %Q|end|
    end

    File.write(path, data)
    puts "Created #{path}"
  end
end


aws_go_path  = ARGV.shift? || raise ArgumentError.new("arg1: missing aws-go path")
service_name = ARGV.shift? || raise ArgumentError.new("arg1: missing service name")
json_path = `find #{aws_go_path}/models/apis/#{service_name} -name 'api*.json' | head -1`.chomp
# gen/aws-sdk-go/models/apis/sqs/2012-11-05/api-2.json

gen = GenCode.new(service_name, json_path)
gen.gen_types
gen.gen_api
