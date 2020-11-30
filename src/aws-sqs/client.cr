require "./execute"

module Aws
  module SQS
    class Client
      property signer : Awscr::Signer::Signers::Interface

      def initialize(@region : String, @aws_access_key : String, @aws_secret_key : String, @endpoint : String? = nil, signer : Symbol = :v4)
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
