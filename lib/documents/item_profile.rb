module Documents
  class ItemProfile
    attr_reader :name, :unit

    def initialize(item, config)
      @item = item
      @config = config
      @unit = config['business_unit']
      @name = "#{@unit}_ItemProfile_#{item['sku']}_#{date_stamp}.xml"
    end

    def to_xml
      item_profile ={
        'ClientID' => @config['client_id'],
        'BusinessUnit' => @unit,
        'ItemNo' => @item['sku'],
        'UPCno' => @item['upc'] || @item['sku'],
        'StockWgt' => @item['stock_weight'] || "1.0000",
        'StockUOM' => @item['stock_uom'] || "EA",
        'ItemDesc' => @item['description'],
        'ImageUrl' => @item['image_url'],
        'ItemSize' => @item['item_size'],
        'ItemMaterial' => @item['item_material'],
        'ItemColor' => @item['item_color'],
        'CommodityClass' => @item['commodity_class'],
        'CommodityDesc' => @item['commodity_desc'],
        'VendorName' => @item['vendor_name'],
        'VendorItemNo' => @item['vendor_item_no']
      }.compact

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ItemProfileDocument('xmlns' => 'http://schemas.quietlogistics.com/V2/ItemProfile.xsd') {
          xml.ItemProfile(item_profile) {
            xml.UnitQuantity('BarCode' => determine_barcode, 'Quantity' => (@item['quantity'] || '1'), 'UnitOfMeasure' => 'EA')
          }
        }
      end
      builder.to_xml
    end

    def determine_barcode
      @item['barcode'] || @item['upc'] || @item['sku']
    end

    def date_stamp
      Time.now.strftime('%Y%m%d_%H%M%3N')
    end

    def message
      "ItemProfile Document Successfuly Sent"
    end
  end
end
