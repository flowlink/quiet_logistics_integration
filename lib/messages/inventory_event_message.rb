module Messages
  class InventoryEventMessage
    attr_reader :type

    def initialize(doc, id, receipt_handle)
      @id               = id
      @doc = doc
      @receipt_handle = receipt_handle
    end

    def to_h
      {
        id: @id,
        document_type: 'InventoryEventMessage',
        receipt_handle: @receipt_handle,
        business_unit: @doc.xpath("//@BusinessUnit").first.text,
        inventory_transaction_quantity: @doc.xpath("//@DeltaQuantity").first.text,
        event_type: @doc.xpath("//@EventType").first.text,
        item_number: @doc.xpath("//@ItemNumber").first.text,
        inventory_transaction_reason: @doc.xpath("//@ReasonCode").first.text,
        reference_number: @doc.xpath("//@EventId").first.text,
        inventory_transaction_date: @doc.xpath("//@EventTime").first.text
      }
    end
  end
end