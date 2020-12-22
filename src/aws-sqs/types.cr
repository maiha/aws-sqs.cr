require "./gen/types"

module Aws::SQS::Types
  record DefaultResult do
    include Output
  end

  class ReceiveMessageResponse(I, R)
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

    var xml : Utils::XML = Utils::XML.new(response.body)

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


