require "../src/aws-sqs"

region = ENV["AWS_DEFAULT_REGION"]
access = ENV["AWS_ACCESS_KEY_ID"]
secret = ENV["AWS_SECRET_ACCESS_KEY"]

prefix = ARGV.shift?

client = Aws::SQS::Client.new(region: region, aws_access_key: access, aws_secret_key: secret)
res = client.list_queues(queue_name_prefix: prefix)
p res
