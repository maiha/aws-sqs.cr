require "../spec_helper"

module Aws::SQS
  module Utils
    describe SignerFactory do
      it "can return v2 signers" do
        signer = SignerFactory.get("sqs","region", "key", "secrety", version: :v2)
        signer.should be_a(Awscr::Signer::Signers::V2)
      end

      it "can return v4 signers" do
        signer = SignerFactory.get("sqs", "region", "key", "secrety", version: :v4)
        signer.should be_a(Awscr::Signer::Signers::V4)
      end

      it "raises on invalid version" do
        expect_raises(Exception) do
          SignerFactory.get("sqs", "region", "key", "secrety", version: :v1)
        end
      end
    end
  end
end
