module Documents
  class RMAResult
    attr_reader :type

    def initialize(xml)
      @doc  = Nokogiri::XML(xml).remove_namespaces!
      @type = :rma
      @number = @doc.xpath("//@RMANumber").first.text
      @receipt_date = @doc.xpath("//@ReceiptDate").first.text
      @warehouse = @doc.xpath("//@Warehouse").first.text
      @business_unit = @doc.xpath('//@BusinessUnit').first.value
      @doc.xpath("//@BusinessUnit").first.text
    end

    def to_flowlink_hash
      {
        id: "#{@number}-#{Time.now.strftime('%Y%m%d%H%M%S%L')}",
        rma_number: @number,
        business_unit: @business_unit,
        receipt_date: @receipt_date,
        warehouse: @warehouse,
        items: items_hash
      }
    end

    def items_hash
      @doc.xpath("//Line").collect do |item|
        {
          line_number:    item['LineNo'],
          sku:            item['ItemNumber'],
          quantity:       item['Quantity'],
          product_status: item['ProductStatus'],
          order_number:   item['OrderNumber']
        }
      end
    end
  end
end
