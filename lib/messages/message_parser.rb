module Messages
  class MessageParser

    def self.parse(sqs_message)
      doc  = Nokogiri::XML(sqs_message.body)
      id = sqs_message.message_id
      type = doc.children[0].name
      receipt_handle = sqs_message.receipt_handle

      msg = if type == 'ErrorMessage'
              ErrorMessage.new(doc, id, receipt_handle)
            elsif type == 'Acknowledgment'
              AcknowledgmentMessage.new(doc, id, receipt_handle)
            elsif type == "EventMessage"
              IncomingEventMessage.new(doc, id, receipt_handle)
            elsif type == 'InventoryEventMessage'
              msg = InventoryEventMessage.new(doc, id, receipt_handle)
            else
              {}
            end

      msg.to_h
    end
  end
end