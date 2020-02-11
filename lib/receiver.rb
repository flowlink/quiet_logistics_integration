class Receiver
  attr_reader :sqs, :count

  def initialize(queue_name, iterations)
    @sqs = Aws::SQS::Resource.new
    @iterations = (iterations || 4).to_i
    @limit = 10
    @queue_name = queue_name
    @count = 0
  end

  def receive_messages
    queue = @sqs.queue(@queue_name)

    @iterations.times do
      messages = queue.receive_messages(max_number_of_messages: @limit)
      messages.each do |sqs_message|
        msg = Messages::MessageParser.parse(sqs_message)

        next if msg.empty?
        @count += 1

        yield(msg)
      end
    end
  end

  def receive_errors
    queue = @sqs.queue(@queue_name)

    @iterations.times do
      messages = queue.receive_messages(max_number_of_messages: @limit)
      messages.each do |sqs_message|
        msg = Messages::MessageParser.parse(sqs_message)

        next if msg.empty?
        next if msg[:document_type] != "error"
        @count += 1

        yield(msg)
      end
    end
  end
end
