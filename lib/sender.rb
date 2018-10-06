class Sender
  attr_reader :sqs

  def initialize(bucket)
    @sqs = Aws::SQS::Resource.new
    @queue_name = bucket
  end

  def send_message(event_message)
    queue = sqs.queue(@queue_name)
    sqs_message = queue.send_message(event_message.to_xml)
    sqs_message.id
  end
end
