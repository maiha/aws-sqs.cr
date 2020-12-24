require "./api"
require "./execute"

module Aws
  module SQS
    class Client
      property signer : Awscr::Signer::Signers::Interface

      property region : String
      property endpoint : URI
      
      def initialize(@region : String, @aws_access_key : String, @aws_secret_key : String, endpoint : String? = nil, signer : Symbol = :v4)
        @endpoint = URI.parse(endpoint || "http://#{SERVICE_NAME}.#{@region}.amazonaws.com".sub(/\.\./, "."))

        @signer = Utils::SignerFactory.get(
          service_name: SERVICE_NAME,
          version: signer,
          region: @region,
          aws_access_key: @aws_access_key,
          aws_secret_key: @aws_secret_key
        )
      end

      include API
      include Execute
    end
  end
end
