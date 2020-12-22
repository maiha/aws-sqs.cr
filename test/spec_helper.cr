require "spec"
require "json"

require "../src/aws-sqs"

module LocalStack
  ENDPOINT       = "http://localstack:4566"
  REGION         = "us-east-2"
  AWS_ACCESS_KEY = "dummy"
  AWS_SECRET_KEY = "dummy"

  class Health
    include JSON::Serializable
    # {"services": {"sqs": "running"}}
    property services : Hash(String, String)
  end
end

def localstack_services : Hash(String, String)
  res = HTTP::Client.get("#{LocalStack::ENDPOINT}/health")
  LocalStack::Health.from_json(res.body).services
end
