require "../src/aws-sqs"

USAGE = <<-EOF
  usage: send_message.cr <QUEUE_URL> [<MESSAGE_BODY>]
    ENV["AWS_DEFAULT_REGION"]    : #{ENV["AWS_DEFAULT_REGION"]? || "(not found)"}
    ENV["AWS_ACCESS_KEY_ID"]     : #{ENV["AWS_ACCESS_KEY_ID"]? ? "OK" : "(not found)"}
    ENV["AWS_SECRET_ACCESS_KEY"] : #{ENV["AWS_SECRET_ACCESS_KEY"]? ? "OK" : "(not found)"}

    example)
      crystal samples/send_message.cr "https://sqs.us-east-2.amazonaws.com/123456789012/MyQueue" "hello"

  EOF

# arg1: queue_url
queue_url = ARGV.shift?
if queue_url
  unless queue_url =~ %r{^https://}
    queue_url = nil
  end
end

# arg2: message_body
message_body = ARGV.shift? || "Hello from Crystal [#{Time.local}]"

if queue_url 
  region = ENV["AWS_DEFAULT_REGION"]
  access = ENV["AWS_ACCESS_KEY_ID"]
  secret = ENV["AWS_SECRET_ACCESS_KEY"]

  client = Aws::SQS::Client.new(region: region, aws_access_key: access, aws_secret_key: secret)
  res = client.send_message(queue_url: queue_url, message_body: message_body, message_group_id: "g1")
  p res
else
  puts USAGE
end
