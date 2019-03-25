class Processor

  def initialize(bucket)
    @bucket = bucket
  end

  def process_doc(msg)
    name = msg['document_name']
    type = msg['document_type']

    if type == 'InventoryEventMessage'
      data = msg
    else
      downloader = Downloader.new(@bucket)
      data = downloader.download(name)
    end

    # Not cool to delete it! we are separating the endpoints, so it is better not
    # to delete it.
    # downloader.delete_file(name)

    parse_doc(type, data)
  end

  private

  def parse_doc(type, data)
    case type
    when 'ShipmentOrderResult'
      Documents::ShipmentOrderResult.new(data)
    when 'ShipmentOrderCancelReady'
      Documents::ShipmentOrderCancelReady.new(data)
    when 'PurchaseOrderReceipt'
      Documents::PurchaseOrderReceipt.new(data)
    when 'RMAResultDocument'
      Documents::RMAResult.new(data)
    when 'InventoryEventMessage'
      Documents::InventoryAdjustment.new(data)
    else
      Struct.new(:type).new(:unknown)
    end
  end
end
