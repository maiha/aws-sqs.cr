require "uri"
require "xml"

module Aws::SQS
  module Utils
    class Http
      # Exception raised when Sqs gives us a non 200 http status code. The error
      # will have a specific message from Sqs.
      class ServerError < Exception
        # Creates a `ServerError` from an `HTTP::Client::Response`
        def self.from_response(response)
          xml = XML.new(response.body)

          code = xml.string("//Error/Code")
          message = xml.string("//Error/Message")

          new("#{code}: #{message}")
        end
      end

      def initialize(@signer : Awscr::Signer::Signers::Interface, endpoint : URI | String)
        @endpoint = endpoint.is_a?(String) ? URI.parse(endpoint) : endpoint

        @http = HTTP::Client.new(@endpoint)

        @http.before_request do |request|
          @signer.sign(request)
        end
      end

      # Issue a DELETE request to the *path* with optional *headers*
      #
      # ```
      # http = Http.new(signer)
      # http.delete("/")
      # ```
      def delete(path, headers : Hash(String, String) = Hash(String, String).new)
        headers = HTTP::Headers.new.merge!(headers)
        resp = @http.delete(path, headers: headers)
        handle_response!(resp)
      end

      # Issue a POST request to the *path* with optional *headers*, and *body*
      #
      # ```
      # http = Http.new(signer)
      # http.post("/", body: IO::Memory.new("test"))
      # ```
      def post(path, body = nil, headers : Hash(String, String) = Hash(String, String).new)
        headers = HTTP::Headers.new.merge!(headers)
        resp = @http.post(path, headers: headers, body: body)
        handle_response!(resp)
      end

      # Issue a PUT request to the *path* with optional *headers* and *body*
      #
      # ```
      # http = Http.new(signer)
      # http.put("/", body: IO::Memory.new("test"))
      # ```
      def put(path : String, body : IO | String, headers : Hash(String, String) = Hash(String, String).new)
        headers = HTTP::Headers{"Content-Length" => body.size.to_s}.merge!(headers)
        resp = @http.put(path, headers: headers, body: body)
        handle_response!(resp)
      end

      # Issue a HEAD request to the *path*
      #
      # ```
      # http = Http.new(signer)
      # http.head("/")
      # ```
      def head(path)
        resp = @http.head(path)
        handle_response!(resp)
      end

      # Issue a GET request to the *path*
      #
      # ```
      # http = Http.new(signer)
      # http.get("/")
      # ```
      def get(path)
        resp = @http.get(path)
        handle_response!(resp)
      end

      # Issue an arbitrary request by delegating to `HTTP#exec`
      #
      # ```
      # http = Http.new(signer)
      # http.exec(HTTP::Request.new("GET", "/"))
      # ```
      def exec(request : HTTP::Request)
        resp = @http.exec(request)
        handle_response!(resp)
      end

      # :nodoc:
      private def handle_response!(response)
        return response if (200..299).includes?(response.status_code)

        if !response.body.empty?
          raise ServerError.from_response(response)
        else
          raise ServerError.new("server error: #{response.status_code}")
        end
      end
    end
  end
end
