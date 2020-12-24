module Aws
  module SQS
    module Execute
      # ```
      # params  = build_params(action: "ReceiveMessage", version: "2012-11-05", request: user_request)
      # request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params)
      # execute(http_request, user_request)
      # ```
      def build_params(action : String, version : String, input : Types::Input) : HTTP::Params
        params = HTTP::Params.new
        params["Action"]  = action
        params["Version"] = version

        set_params(params, serializer: self, value: input)

        return params
      end

      def build_request(method : String, resource : String, headers : (HTTP::Headers | Hash(String, String))? = nil, params : HTTP::Params? = nil) : HTTP::Request
        headers = HTTP::Headers.new.tap(&.merge!(headers)) if headers.is_a?(Hash)

        if params
          body = params.to_s
        else
          body = nil
        end

        http_request = HTTP::Request.new(method: method, resource: resource, headers: headers, body: body)
        
        return http_request
      end

      def execute(http_request, user_request : Types::Input, output : T.class) forall T
        http.exec(http_request)
      end

      # :nodoc:
      private def http
        Utils::Http.new(signer: @signer, endpoint: endpoint)
      end
      
      ######################################################################
      ### Serialize request

      def set_params(params : HTTP::Params, serializer : Execute, value : Types::InputList)
        value.set_params(params, serializer)
      end

      def set_params(params : HTTP::Params, serializer : Execute, value : Types::Input)
        value.set_params(params, serializer)
      end

      def set_params(params : HTTP::Params, serializer : Execute, name : String, value : Types::InputList)
        value.set_params(params, serializer)
      end

      def set_params(params : HTTP::Params, serializer : Execute, name : String, value)
        params[name] = value.to_s
      end
    end
  end
end
