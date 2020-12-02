# Generated by gen-code.cr
#     DO NOT EDIT THIS FILE BY HAND -- YOUR CHANGES WILL BE OVERWRITTEN

require "./types"

module Aws::SQS::API
  include Types

  def add_permission(queue_url : String, label : String, aws_account_ids : AWSAccountIdList, actions : ActionNameList)
    input = AddPermissionRequest.new(
      queue_url: queue_url,
      label: label,
      aws_account_ids: aws_account_ids,
      actions: actions,
    )
    params  = build_params(action: "AddPermission", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def change_message_visibility(queue_url : String, receipt_handle : String, visibility_timeout : Integer)
    input = ChangeMessageVisibilityRequest.new(
      queue_url: queue_url,
      receipt_handle: receipt_handle,
      visibility_timeout: visibility_timeout,
    )
    params  = build_params(action: "ChangeMessageVisibility", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def change_message_visibility_batch(queue_url : String, entries : ChangeMessageVisibilityBatchRequestEntryList)
    input = ChangeMessageVisibilityBatchRequest.new(
      queue_url: queue_url,
      entries: entries,
    )
    params  = build_params(action: "ChangeMessageVisibilityBatch", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def create_queue(queue_name : String, attributes : QueueAttributeMap? = nil, tags : TagMap? = nil)
    input = CreateQueueRequest.new(
      queue_name: queue_name,
      attributes: attributes,
      tags: tags,
    )
    params  = build_params(action: "CreateQueue", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def delete_message(queue_url : String, receipt_handle : String)
    input = DeleteMessageRequest.new(
      queue_url: queue_url,
      receipt_handle: receipt_handle,
    )
    params  = build_params(action: "DeleteMessage", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def delete_message_batch(queue_url : String, entries : DeleteMessageBatchRequestEntryList)
    input = DeleteMessageBatchRequest.new(
      queue_url: queue_url,
      entries: entries,
    )
    params  = build_params(action: "DeleteMessageBatch", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def delete_queue(queue_url : String)
    input = DeleteQueueRequest.new(
      queue_url: queue_url,
    )
    params  = build_params(action: "DeleteQueue", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def get_queue_attributes(queue_url : String, attribute_names : AttributeNameList? = nil)
    input = GetQueueAttributesRequest.new(
      queue_url: queue_url,
      attribute_names: attribute_names,
    )
    params  = build_params(action: "GetQueueAttributes", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def get_queue_url(queue_name : String, queue_owner_aws_account_id : String? = nil)
    input = GetQueueUrlRequest.new(
      queue_name: queue_name,
      queue_owner_aws_account_id: queue_owner_aws_account_id,
    )
    params  = build_params(action: "GetQueueUrl", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def list_dead_letter_source_queues(queue_url : String, next_token : Token? = nil, max_results : BoxedInteger? = nil)
    input = ListDeadLetterSourceQueuesRequest.new(
      queue_url: queue_url,
      next_token: next_token,
      max_results: max_results,
    )
    params  = build_params(action: "ListDeadLetterSourceQueues", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def list_queue_tags(queue_url : String)
    input = ListQueueTagsRequest.new(
      queue_url: queue_url,
    )
    params  = build_params(action: "ListQueueTags", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def list_queues(queue_name_prefix : String? = nil, next_token : Token? = nil, max_results : BoxedInteger? = nil)
    input = ListQueuesRequest.new(
      queue_name_prefix: queue_name_prefix,
      next_token: next_token,
      max_results: max_results,
    )
    params  = build_params(action: "ListQueues", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def purge_queue(queue_url : String)
    input = PurgeQueueRequest.new(
      queue_url: queue_url,
    )
    params  = build_params(action: "PurgeQueue", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def receive_message(queue_url : String, attribute_names : AttributeNameList? = nil, message_attribute_names : MessageAttributeNameList? = nil, max_number_of_messages : Integer? = nil, visibility_timeout : Integer? = nil, wait_time_seconds : Integer? = nil, receive_request_attempt_id : String? = nil)
    input = ReceiveMessageRequest.new(
      queue_url: queue_url,
      attribute_names: attribute_names,
      message_attribute_names: message_attribute_names,
      max_number_of_messages: max_number_of_messages,
      visibility_timeout: visibility_timeout,
      wait_time_seconds: wait_time_seconds,
      receive_request_attempt_id: receive_request_attempt_id,
    )
    params  = build_params(action: "ReceiveMessage", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def remove_permission(queue_url : String, label : String)
    input = RemovePermissionRequest.new(
      queue_url: queue_url,
      label: label,
    )
    params  = build_params(action: "RemovePermission", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def send_message(queue_url : String, message_body : String, delay_seconds : Integer? = nil, message_attributes : MessageBodyAttributeMap? = nil, message_system_attributes : MessageBodySystemAttributeMap? = nil, message_deduplication_id : String? = nil, message_group_id : String? = nil)
    input = SendMessageRequest.new(
      queue_url: queue_url,
      message_body: message_body,
      delay_seconds: delay_seconds,
      message_attributes: message_attributes,
      message_system_attributes: message_system_attributes,
      message_deduplication_id: message_deduplication_id,
      message_group_id: message_group_id,
    )
    params  = build_params(action: "SendMessage", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def send_message_batch(queue_url : String, entries : SendMessageBatchRequestEntryList)
    input = SendMessageBatchRequest.new(
      queue_url: queue_url,
      entries: entries,
    )
    params  = build_params(action: "SendMessageBatch", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def set_queue_attributes(queue_url : String, attributes : QueueAttributeMap)
    input = SetQueueAttributesRequest.new(
      queue_url: queue_url,
      attributes: attributes,
    )
    params  = build_params(action: "SetQueueAttributes", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def tag_queue(queue_url : String, tags : TagMap)
    input = TagQueueRequest.new(
      queue_url: queue_url,
      tags: tags,
    )
    params  = build_params(action: "TagQueue", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

  def untag_queue(queue_url : String, tag_keys : TagKeyList)
    input = UntagQueueRequest.new(
      queue_url: queue_url,
      tag_keys: tag_keys,
    )
    params  = build_params(action: "UntagQueue", version: "2012-11-05", input: input)
    request = build_request("POST", "/", headers: {"Content-Type" => "application/x-www-form-urlencoded"}, params: params)
    execute(request, input)
  end

end
