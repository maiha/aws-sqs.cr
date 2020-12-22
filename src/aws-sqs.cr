require "awscr-signer"
require "var"

require "./aws-sqs/**"

module Aws::SQS
  SERVICE_NAME = "sqs"

  include Types
end
  
