require "../spec_helper"

private def queue_url
  "https://sqs.us-east-2.amazonaws.com/123456789012/MyQueue"
end
      
module Aws
  module SQS
    describe Client do
      it "allows signer version" do
        Client.new("adasd", "adasd", "adad", signer: :v2)
      end

      it "delete_message(queue_url, receipt_handle)" do
        expect_http_request(
          :post, "http://sqs.us-east-2.amazonaws.com/", headers: {"Content-Type" => "application/x-www-form-urlencoded"},
          body: "Action=DeleteMessage&Version=2012-11-05&QueueUrl=https%3A%2F%2Fsqs.us-east-2.amazonaws.com%2F123456789012%2FMyQueue&ReceiptHandle=foo",
        ) do
          client = Client.new("us-east-2", "key", "secret")
          client.delete_message(queue_url: queue_url, receipt_handle: "foo")
        end
      end

      it "get_queue_attributes(queue_url)" do
        expect_http_request(
          :post, "http://sqs.us-east-2.amazonaws.com/", headers: {"Content-Type" => "application/x-www-form-urlencoded"},
          body: "Action=GetQueueAttributes&Version=2012-11-05&QueueUrl=https%3A%2F%2Fsqs.us-east-2.amazonaws.com%2F123456789012%2FMyQueue"
        ) do
          client = Client.new("us-east-2", "key", "secret")
          client.get_queue_attributes(queue_url: queue_url)
        end
      end

      it "get_queue_attributes(queue_url, attribute_names)" do
        expect_http_request(
          :post, "http://sqs.us-east-2.amazonaws.com/", headers: {"Content-Type" => "application/x-www-form-urlencoded"},
          body: "Action=GetQueueAttributes&Version=2012-11-05&QueueUrl=https%3A%2F%2Fsqs.us-east-2.amazonaws.com%2F123456789012%2FMyQueue&AttributeName.1=QueueArn&AttributeName.2=ApproximateNumberOfMessages"
        ) do
          client = Client.new("us-east-2", "key", "secret")
          attribute_names = AttributeNameList.new([QueueAttributeName::QueueArn, QueueAttributeName::ApproximateNumberOfMessages])
          client.get_queue_attributes(queue_url: queue_url, attribute_names: attribute_names)
        end
      end

      it "list_queues" do
        expect_http_request(
          :post, "http://sqs.us-east-2.amazonaws.com/", headers: {"Content-Type" => "application/x-www-form-urlencoded"},
          body: "Action=ListQueues&Version=2012-11-05"
        ) do
          client = Client.new("us-east-2", "key", "secret")
          client.list_queues
        end
      end

      it "list_queues(queue_name_prefix)" do
        expect_http_request(
          :post, "http://sqs.us-east-2.amazonaws.com/", headers: {"Content-Type" => "application/x-www-form-urlencoded"},
          body: "Action=ListQueues&Version=2012-11-05&QueueNamePrefix=foo",
        ) do
          client = Client.new("us-east-2", "key", "secret")
          client.list_queues(queue_name_prefix: "foo")
        end
      end

      it "receive_message(queue_url)" do
        expect_http_request(
          :post, "http://sqs.us-east-2.amazonaws.com/", headers: {"Content-Type" => "application/x-www-form-urlencoded"},
          body: "Action=ReceiveMessage&Version=2012-11-05&QueueUrl=https%3A%2F%2Fsqs.us-east-2.amazonaws.com%2F123456789012%2FMyQueue",
        ) do
          client = Client.new("us-east-2", "key", "secret")
          client.receive_message(queue_url: queue_url)
        end
      end

      it "send_message(queue_url, message_body)" do
        expect_http_request(
          :post, "http://sqs.us-east-2.amazonaws.com/", headers: {"Content-Type" => "application/x-www-form-urlencoded"},
          body: "Action=SendMessage&Version=2012-11-05&QueueUrl=https%3A%2F%2Fsqs.us-east-2.amazonaws.com%2F123456789012%2FMyQueue&MessageBody=message",
        ) do
          client = Client.new("us-east-2", "key", "secret")
          client.send_message(queue_url: queue_url, message_body: "message")
        end
      end

      it "send_message(queue_url, message_body, message_group_id)" do
        expect_http_request(
          :post, "http://sqs.us-east-2.amazonaws.com/", headers: {"Content-Type" => "application/x-www-form-urlencoded"},
          body: "Action=SendMessage&Version=2012-11-05&QueueUrl=https%3A%2F%2Fsqs.us-east-2.amazonaws.com%2F123456789012%2FMyQueue&MessageBody=message&MessageGroupId=g1",
        ) do
          client = Client.new("us-east-2", "key", "secret")
          client.send_message(queue_url: queue_url, message_body: "message", message_group_id: "g1")
        end
      end

      it "send_message(queue_url, message_body, message_group_id, message_deduplication_id)" do
        expect_http_request(
          :post, "http://sqs.us-east-2.amazonaws.com/", headers: {"Content-Type" => "application/x-www-form-urlencoded"},
          body: "Action=SendMessage&Version=2012-11-05&QueueUrl=https%3A%2F%2Fsqs.us-east-2.amazonaws.com%2F123456789012%2FMyQueue&MessageBody=message&MessageDeduplicationId=d1&MessageGroupId=g1",
        ) do
          client = Client.new("us-east-2", "key", "secret")
          client.send_message(queue_url: queue_url, message_body: "message", message_group_id: "g1", message_deduplication_id: "d1")
        end
      end
    end
  end
end
