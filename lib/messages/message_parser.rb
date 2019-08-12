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
    
    def self.is_regexp_match?(msg, config)
      return true unless config['regex_items'] && config['regex_items'] != ""

      regex = JSON.parse(config['regex_items']).first[msg['document_type']]
      
      return false if regex.nil?

      return true if msg["document_name"].match(Regexp.new(regex))

      return false
    end
  end
end