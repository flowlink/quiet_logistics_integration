module Messages
  class AcknowledgmentMessage

    def initialize(doc, id, receipt_handle)
      @sqs_id   = id
      @receipt_handle = receipt_handle
      @doc = doc
    end

    def to_h
      {
        id: @sqs_id,
        document_type: @doc.xpath("//@OriginalDocumentType").first.text,
        receipt_handle: @receipt_handle,
        doc_name: @doc.xpath("//@OriginalDocumentName").first.text,
        doc_key: @doc.xpath("//@OriginalDocumentKey").first.text
      }
    end
  end
end