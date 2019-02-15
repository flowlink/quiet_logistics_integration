# frozen_string_literal: true

module Documents
  class ShipmentOrderCancel
    attr_reader :name, :unit

    def initialize(order, config)
      @order          = order
      @config         = config
      @order_number   = order['id']
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ShipmentOrderCancel(
          'xmlns' => 'http://schemas.quietlogistics.com/V2/ShipmentOrderCancel.xsd',
          'ClientID'     => @config['client_id'],
          'BusinessUnit' => @config['business_unit'],
          'OrderNumber'  => @order_number
        )
      end.to_xml
    end

    def message
      'Succesfully Sent Shipment Order Cancel to QL'
    end

    def date_stamp
      Time.now.strftime('%Y%m%d_%H%M%3N')
    end
  end
end
