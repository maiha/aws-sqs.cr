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
    getter klass
    getter name
    getter type
    getter required

    def initialize(@klass : String, @name : String, @type : String, @required : Bool)
    end

    def to_param_key : String
      klass
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

    include Enumerable(Field)

    def each(&block : Field -> _)
      nil
    end
  end

  class ShapeBlob < Shape
  end

  class ShapeBoolean < Shape
  end

  class ShapeInteger < Shape
  end

  class ShapeString < Shape
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
    #     "type": "list",
    #     "member": {
    #       "shape": "String",
    #       "locationName": "ActionName"
    #     },
    #     "flattened": true
    property member : Hash(String, String)
    #      property flattended : Bool
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
        type = hash["shape"]
        case type
        when Bool
          raise ArgumentError.new("shape is bool: name=[#{name}], hash=#{hash.inspect}")

        when String
          field = Field.new(
            klass: name,
            name: name.underscore,
            type: type,
            required: !!required.try(&.includes?(name)),
          )
          yield field
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
      # Generated by #{__FILE__}
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
      s.puts %Q|    abstract def fill(params : HTTP::Params, serializer)|
      s.puts %Q|  end|
      s.puts
      
      shapes.each do |name, shape|
        next if ignore_type?(name)
        s.print %Q|  record #{name}|

        if shape.any?
          name_maxlen = shape.map(&.name.size).max
          shape.each do |f|
            fixed_name = f.name.ljust(name_maxlen)
            nullable = f.required ? "" : "?"
            s.print %Q|,\n    #{fixed_name} : #{f.type}#{nullable}|
          end
        end

        if name =~ /Request$/
          s.puts %Q| do|
          s.puts
          s.puts %Q|    include Input|
          s.puts
          s.puts %Q|    def fill(params : HTTP::Params, serializer)|
          shape.each do |f|
            s.puts %Q|      params["#{f.to_param_key}"] = serializer.serialize(#{f.name}) if !#{f.name}.nil?|
          end
          s.puts %Q|    end|
          s.puts %Q|  end|
        else
          s.puts
        end

        s.puts
      end

      s.puts %Q|end|
    end

    File.write(path, data)
    puts "Created #{path}"
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

        input_shape_name = op.input["shape"]
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
