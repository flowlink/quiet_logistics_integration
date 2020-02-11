class MessageDeleter
  def initialize(config, payload)
    @sqs = Aws::SQS::Resource.new
    @queue_name = config['ql_incoming_queue']
    @receipt_handle = payload['message']['receipt_handle']
  end

  def delete_message
    queue = @sqs.queue(@queue_name)
    queue.message(@receipt_handle).delete
  end
end
