require "./gen/types"

module Aws::SQS
  class Response(I, R)
    var xml : Utils::XML = Utils::XML.new(response.body)
  end
end

module Aws::SQS::Types
  record DefaultResult do
    include Output
  end

  class GetQueueAttributesResponse(I, R) < Response(I, R)
    # <?xml version="1.0" encoding="UTF-8"?>
    # <GetQueueAttributesResponse>
    #    <GetQueueAttributesResult>
    #       <Attribute>
    #          <Name>QueueArn</Name>
    #          <Value>arn:aws:sqs:ap-northeast-1:000000000000:waiting.fifo</Value>
    #       </Attribute>
    #       <Attribute>
    #          <Name>ApproximateNumberOfMessages</Name>
    #          <Value>4</Value>
    #       </Attribute>
    #       <Attribute>
    #          <Name>MaximumMessageSize</Name>
    #          <Value>262144</Value>
    #       </Attribute>
    #    </GetQueueAttributesResult>
    #    <ResponseMetadata>
    #       <RequestId>TEH441QWJZY6W9S6NJG3LF5KU89AAYS4R9Y6FCC66Z3O8GKH1UPB</RequestId>
    #    </ResponseMetadata>
    # </GetQueueAttributesResponse>

    def attributes
      map = Hash(QueueAttributeName, String).new
      xml.array("//GetQueueAttributesResponse/GetQueueAttributesResult/Attribute") do |node|

        key = QueueAttributeName.parse(node.string("Name"))
        val = node.string("Value")
        map[key] = val
      end

      return map
    end
  end

  class ListQueuesResponse(I, R) < Response(I, R)
    # <?xml version="1.0" encoding="UTF-8"?>
    # <ListQueuesResponse>
    #    <ListQueuesResult>
    #       <QueueUrl>http://localhost:4566/000000000000/waiting.fifo</QueueUrl>
    #       <QueueUrl>http://localhost:4566/000000000000/lookup.fifo</QueueUrl>
    #    </ListQueuesResult>
    #    <ResponseMetadata>
    #       <RequestId>OQYQ577LPLORPZTOYIS8PWH5WSKYXMXWLHJT52PW6B2CESJPLL4D</RequestId>
    #    </ResponseMetadata>
    # </ListQueuesResponse>

    def queue_urls
      urls = Array(String).new

      xml.array("//ListQueuesResponse/ListQueuesResult/QueueUrl") do |node|
        urls << node.text
      end

      return urls
    end
  end
  
  class ReceiveMessageResponse(I, R) < Response(I, R)
    # <?xml version="1.0" encoding="UTF-8"?>
    # <ReceiveMessageResponse>
    #    <ReceiveMessageResult>
    #       <Message>
    #          <MessageId>6d5110b9-c4d1-13ad-11ff-65fb62b99995</MessageId>
    #          <ReceiptHandle>hiowpgjwdpswdvanyysslzdoppnezgfhvqejccqfzylhrsydaiklkqoboplxhcgwlevoobioyfhpckscwhxxwdtoaalpxloirmjxutzjsrgmdebncrjqrqzeoejxshpohsrtgdpdzyakpkaoxglzvnrlvwiwlbzurywvgzniymjcicxoljixxfwch</ReceiptHandle>
    #          <MD5OfBody>8b1a9953c4611296a827abf8c47804d7</MD5OfBody>
    #          <Body>Hello</Body>
    #          <Attribute>
    #             <Name>SenderId</Name>
    #             <Value>AIDAIT2UOQQY3AUEKVGXU</Value>
    #          </Attribute>
    #          <Attribute>
    #             <Name>SentTimestamp</Name>
    #             <Value>1608641252751</Value>
    #          </Attribute>
    #          <Attribute>
    #             <Name>ApproximateReceiveCount</Name>
    #             <Value>3</Value>
    #          </Attribute>
    #          <Attribute>
    #             <Name>ApproximateFirstReceiveTimestamp</Name>
    #             <Value>1608641568219</Value>
    #          </Attribute>
    #          <Attribute>
    #             <Name>MessageGroupId</Name>
    #             <Value>g1</Value>
    #          </Attribute>
    #       </Message>
    #    </ReceiveMessageResult>
    #    <ResponseMetadata>
    #       <RequestId>D6XUW89T1V4VJEF5WYMMI2E5SH6R8H7QQ98NT3TNT0OO6MPX5HTV</RequestId>
    #    </ResponseMetadata>
    # </ReceiveMessageResponse>

    def messages
      list = Array(Message).new

      xml.array("//ReceiveMessageResponse/ReceiveMessageResult/Message") do |node|

        msg = Message.new(
          message_id: node.string("MessageId"),
          receipt_handle: node.string("ReceiptHandle"),
          md5_of_body: node.string("MD5OfBody"),
          body: node.string("Body"),
          attributes: nil,
          md5_of_message_attributes: node.string("MD5OfMessageAttributes"),
          message_attributes: nil,
        )
        list << msg
      end

      return list
    end
  end
end
  
