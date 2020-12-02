require "../src/aws-sqs"

USAGE = <<-EOF
  usage: delete_message.cr <QUEUE_URL> [<MESSAGE_BODY>]
    ENV["AWS_DEFAULT_REGION"]    : #{ENV["AWS_DEFAULT_REGION"]? || "(not found)"}
    ENV["AWS_ACCESS_KEY_ID"]     : #{ENV["AWS_ACCESS_KEY_ID"]? ? "OK" : "(not found)"}
    ENV["AWS_SECRET_ACCESS_KEY"] : #{ENV["AWS_SECRET_ACCESS_KEY"]? ? "OK" : "(not found)"}

    example)
      crystal samples/delete_message.cr "https://sqs.us-east-2.amazonaws.com/123456789012/MyQueue" "MbZj6wDWli..."

  EOF

# arg1: queue_url
queue_url = ARGV.shift?
if queue_url
  unless queue_url =~ %r{^https://}
    queue_url = nil
  end
end

# arg2: receipt_handle
receipt_handle = ARGV.shift?

if queue_url && receipt_handle
  region = ENV["AWS_DEFAULT_REGION"]
  access = ENV["AWS_ACCESS_KEY_ID"]
  secret = ENV["AWS_SECRET_ACCESS_KEY"]

  client = Aws::SQS::Client.new(region: region, aws_access_key: access, aws_secret_key: secret)
  res = client.delete_message(queue_url: queue_url, receipt_handle: receipt_handle)
  p res
else
  puts USAGE
end
