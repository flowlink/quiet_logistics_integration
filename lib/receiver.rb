class Receiver
  attr_reader :sqs, :count

  def initialize(queue_name)
    @sqs = Aws::SQS::Resource.new
    @limit = 10
    @queue_name = queue_name
    @count = 0
  end

  def receive_messages
    queue = @sqs.queue(@queue_name)

    4.times do
      queue.receive_messages(max_number_of_messages: @limit) do |sqs_message|
        msg = Messages::MessageParser.parse(sqs_message)

        next if msg.empty?
        @count += 1

        yield(msg)
      end
    end
  end
end