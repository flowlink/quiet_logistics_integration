module Messages
  class IncomingEventMessage

    def initialize(doc, id, receipt_handle)
      @sqs_id = id
      @doc = doc
      @receipt_handle = receipt_handle
    end

    def to_h
      {
        id: @sqs_id,
        document_type: @doc.xpath("//@DocumentType").first.text,
        receipt_handle: @receipt_handle,
        document_name: @doc.xpath("//@DocumentName").first.text,
        business_unit: @doc.xpath("//@BusinessUnit").first.text,
        warehouse: @doc.xpath("//@Warehouse").first.text,
        message_date: @doc.xpath("//@MessageDate").first.text
      }
    end
  end
end