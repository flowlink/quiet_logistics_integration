module Messages
  class ErrorMessage

    def initialize(doc, id, receipt_handle)
      @sqs_id = id
      @receipt_handle = receipt_handle
      @doc = doc
    end

    def to_h
      {
        id: @sqs_id,
        document_type: 'error',
        receipt_handle: @receipt_handle,
        error_code: @doc.xpath("//@ResultCode").first.value,
        error_description: @doc.xpath("//@ResultDescription").first.value,
        response_date: @doc.xpath("//@ResponseDate").first.value
      }
    end
  end
end