module Documents
  class ShipmentOrder
    attr_reader :shipment_number, :order, :shipment, :name, :unit

    def initialize(shipment, config)
      @config          = config
      @shipment        = shipment
      @shipment_number = shipment['id']
      @name            = "#{@config['business_unit']}_ShipmentOrder_#{@shipment_number}_#{date_stamp}.xml"
    end

    def to_xml
      order_header = {
        'OrderNumber' => @shipment_number,
        'OrderType'   => @shipment['order_type'],
        'OrderDate'   => DateTime.now.iso8601,
        'Gift'        => @shipment['gift'] ? 'true' : 'false'
      }


      builder = Nokogiri::XML::Builder.new do |xml|
        xml.ShipOrderDocument('xmlns' => 'http://schemas.quietlogistics.com/V2/ShipmentOrder.xsd') {

          xml.ClientID @config['client_id']
          xml.BusinessUnit @config['business_unit']

          xml.OrderHeader(order_header) {

            xml.Extension shipment['order_number']

            xml.Comments shipment['comments'].to_s


            xml.ShipMode('Carrier'      => @shipment['carrier'],
                         'ServiceLevel' => @shipment['service_level'])

            xml.ShipTo(ship_to_hash)
            xml.BillTo(bill_to_hash)

            xml.ShipSpecialService('SIGNATURE') if @shipment['signature_requested']
            xml.ShipSpecialService(@shipment['special_service']) if @shipment['special_service']
            xml.DeclaredValue(sprintf("%.2f", @shipment['declared_value'])) if @shipment['declared_value']
            xml.Notes('NoteType' => @shipment['note_type'].to_s, 'NoteValue' => @shipment['note_value'].to_s)


            xml.ValueAddedService(
              'Service'     => @shipment['service'],
              'ServiceType' => @shipment['service_type']
            ) if ( @shipment['service_type'] && @shipment['service'] )

          }


          @shipment['items'].collect do |item|
            xml.OrderDetails(line_item_hash(item))
          end
        }
      end
      builder.to_xml
    end

    def line_item_hash(item)
      {
        'ItemNumber'      => item["sku"],
        'Line'            => item['line_number'],
        'QuantityOrdered' => item['quantity'],
        'QuantityToShip'  => item['quantity'],
        'UOM'             => 'EA',
        'Price'           => item['price']
      }
    end

    def ship_to_hash
      {
        'Company'    => company_ship_name,
        'Contact'    => full_name,
        'Address1'   => @shipment['shipping_address']['address1'],
        'Address2'   => @shipment['shipping_address']['address2'],
        'City'       => @shipment['shipping_address']['city'],
        'State'      => @shipment['shipping_address']['state'],
        'PostalCode' => @shipment['shipping_address']['zipcode'],
        'Phone'      => @shipment['shipping_address']['phone'],
        'Email'      => @shipment['shipping_address']['email'],
        'Country'    => @shipment['shipping_address']['country']
      }.compact
    end

    def bill_to_hash
      {
        'Company'    => company_bill_name,
        'Contact'    => full_name,
        'Address1'   => @shipment['billing_address']['address1'],
        'Address2'   => @shipment['billing_address']['address2'],
        'City'       => @shipment['billing_address']['city'],
        'State'      => @shipment['billing_address']['state'],
        'PostalCode' => @shipment['billing_address']['zipcode'],
        'Phone'      => @shipment['billing_address']['phone'],
        'Email'      => @shipment['billing_address']['email'],
        'Country'    => @shipment['billing_address']['country']
      }.compact
    end

    def full_name
      "#{shipment['shipping_address']['firstname']} #{@shipment['shipping_address']['lastname']}"
    end

    def message
      "Succesfully Sent Shipment #{@shipment_number} to Quiet Logistics"
    end

    def date_stamp
      Time.now.strftime('%Y%m%d_%H%M%3N')
    end

    def company_ship_name
      return @shipment['shipping_address']['company'] if @config['use_company_name']

      full_name
    end

    def company_bill_name
      return @shipment['billing_address']['company'] if @config['use_company_name']

      full_name
    end
  end
end
