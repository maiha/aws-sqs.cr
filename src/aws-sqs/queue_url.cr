module Aws
  module SQS
    # queue_url: "https://sqs.us-east-2.amazonaws.com/123456789012/MyQueue"
    class QueueUrl
      delegate path, to: uri

      getter uri

      def initialize(@uri : URI)
      end

      def self.new(url : String)
        new(URI.parse(url))
      end

      def self.new(region : String, account : String, queue_name : String)
        new(URI.parse("https://sqs.#{region}.amazonaws.com/#{account}/#{queue_name}"))
      end
    end
  end
end
