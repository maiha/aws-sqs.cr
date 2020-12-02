require "../src/aws-sqs"

USAGE = <<-EOF
  usage: change_message_visibility.cr <QUEUE_URL> <RECEIPT_HANDLE> <VISIBILITY_TIMEOUT>
    ENV["AWS_DEFAULT_REGION"]    : #{ENV["AWS_DEFAULT_REGION"]? || "(not found)"}
    ENV["AWS_ACCESS_KEY_ID"]     : #{ENV["AWS_ACCESS_KEY_ID"]? ? "OK" : "(not found)"}
    ENV["AWS_SECRET_ACCESS_KEY"] : #{ENV["AWS_SECRET_ACCESS_KEY"]? ? "OK" : "(not found)"}

    example)
      crystal samples/change_message_visibility.cr "https://sqs.us-east-2.amazonaws.com/123456789012/MyQueue" "MbZj6wDWli..." 60

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

# arg3: receipt_handle
visibility_timeout = ARGV.shift?.try(&.to_i)

if queue_url && receipt_handle && visibility_timeout
  region = ENV["AWS_DEFAULT_REGION"]
  access = ENV["AWS_ACCESS_KEY_ID"]
  secret = ENV["AWS_SECRET_ACCESS_KEY"]

  client = Aws::SQS::Client.new(region: region, aws_access_key: access, aws_secret_key: secret)
  res = client.change_message_visibility(queue_url: queue_url, receipt_handle: receipt_handle, visibility_timeout: visibility_timeout)
  p res
else
  puts USAGE
end
