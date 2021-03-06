require "./spec_helper"

module LocalStack
  def self.client
    Aws::SQS::Client.new(REGION, AWS_ACCESS_KEY, AWS_SECRET_KEY, endpoint: ENDPOINT)
  end

  QUEUE_URL = "http://localstack:4566/000000000000/MyQueue.fifo"
  
  describe "Integration test on LocalStack" do
    it "sqs is running" do
      localstack_services["sqs"]?.should eq("running")

      # TODO: ensures the queue has been created.
      # AWS.SimpleQueueService.NonExistentQueue: The specified queue does not exist for this wsdl version. (Aws::SQS::Utils::Http::ServerError)
    end

    it "produces" do
      res = client.send_message(queue_url: QUEUE_URL, message_body: "Hello", message_group_id: "g1")
      res.status.should eq(HTTP::Status::OK)
    end

    it "consumes" do
      res = client.receive_message(queue_url: QUEUE_URL)
      res.status.should eq(HTTP::Status::OK)
      res.body.should contain("Hello")
    end
  end
end
