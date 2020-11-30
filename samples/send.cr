require "../src/aws-sqs"

USAGE = <<-EOF
  usage: send.cr <QUEUE_URL>
    ENV["AWS_DEFAULT_REGION"]    : #{ENV["AWS_DEFAULT_REGION"]? || "(not found)"}
    ENV["AWS_ACCESS_KEY_ID"]     : #{ENV["AWS_ACCESS_KEY_ID"]? ? "OK" : "(not found)"}
    ENV["AWS_SECRET_ACCESS_KEY"] : #{ENV["AWS_SECRET_ACCESS_KEY"]? ? "OK" : "(not found)"}
  EOF

queue_url = ARGV.shift?
if queue_url
  unless queue_url =~ %r{^https://}
    queue_url = nil
  end
end

if queue_url 
  region = ENV["AWS_DEFAULT_REGION"]
  access = ENV["AWS_ACCESS_KEY_ID"]
  secret = ENV["AWS_SECRET_ACCESS_KEY"]

  client = Aws::SQS::FIFOClient.new(region: region, aws_access_key: access, aws_secret_key: secret)
  res = client.send_message(queue_url: queue_url, body: "Hello from Crystal [#{Time.local}]", group_id: "g1")
  p res
else
  puts USAGE
end
