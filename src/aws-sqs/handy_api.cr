module Aws::SQS::HandyAPI

  def get_queue_attributes(queue_url : String, attribute_names : Array(QueueAttributeName))
    get_queue_attributes(queue_url, AttributeNameList.new(attribute_names))
  end

  def get_queue_attributes(queue_url : String, attribute_names : Array(String))
    get_queue_attributes(queue_url, attribute_names.map{|v| QueueAttributeName.parse(v)})
  end

end
