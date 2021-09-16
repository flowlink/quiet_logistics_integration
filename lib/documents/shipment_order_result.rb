# frozen_string_literal: true

#
# A ShipmentOrderResult lists items shipped, tracking number, carrier
# information, and packaging details.
#
# The structure of the XML document is:
#
#   <SOResult ...>
#     <Line ... />
#     <Line ... />
#     <Line ... />
#     <Carton ... >
#       <Content ... />
#       <Content ... />
#     </Carton>
#     <Carton ... >
#       <Content ... />
#     </Carton>
#     <Extension />
#   </SOResult>
#
# See the specs for a full example.

module Documents
  class ShipmentOrderResult
    NAMESPACE = 'http://schemas.quiettechnology.com/V2/SOResultDocument.xsd'

    attr_reader :type

    def initialize(xml, msg)
      @doc = Nokogiri::XML(xml)
      @type = :shipment
      @message = msg
    end

    def to_flowlink_hash
      id = @doc.xpath('//@OrderNumber').first.text
      relation = 'order_number'
      relation = @message['ql_relationships'] if @message['ql_relationships']
      id = update_id if @message['ql_remove_prefix']

      {
        id: id,
        quietlogistics_id: id,
        order_number: @doc.xpath('//@OrderNumber').first.text,
        # NOTE: There may multiple tracking numbers. This is just the first.
        tracking_numbers: tracking_numbers,
        shipping_method: shipping_method,
        warehouse: @doc.xpath('//@Warehouse').first.text,
        status: 'shipped',
        business_unit: @doc.xpath('//@BusinessUnit').first.value,
        shipped_at: @doc.xpath('//@DateShipped').first.text,
        tracking_company: @doc.xpath('//@Carrier').first.text,
        line_items: line_items_to_h,
        order: {
          relation => id
        },
        relationships: [
          {
            object: 'order', key: relation
          }
        ]
      }
    end

    private

    def shipping_method
      @doc.xpath('//@Carrier').first.text
      + ' '
      + @doc.xpath('//@ServiceLevel').first.text
    end

    def tracking_numbers
      line_items_to_h.map { |item| item[:tracking_number] }.uniq
    end

    def update_id
      order_number = @doc.xpath('//@OrderNumber').first.text
      title = order_number.split('-')
      case title.size
      when 1
        title[0].strip
      when 2
        title[1].strip
      else
        title[1..-1].join('-').strip
      end
    end

    def line_items_to_h
      line_items = []
      cartons = @doc.xpath('ql:SOResult/ql:Carton', 'ql' => NAMESPACE)
      cartons.each do |carton|
        contents = carton.xpath('ql:Content', 'ql' => NAMESPACE)
        contents.each do |content|
          line_items << {
            carton_id: carton['CartonId'],
            tracking_number: carton['TrackingId'],
            product_id: content['ItemNumber'],
            quantity: Integer(content['Quantity'])
          }
        end
      end
      line_items
    end

    # def carton_line_items_to_h(carton)
    #   contents = carton.xpath('ql:Content', 'ql' => NAMESPACE)
    #   contents.map do |content|
    #     {
    #       ql_item_number: content['ItemNumber'],
    #       quantity: Integer(content['Quantity'])
    #     }
    #   end
    # end
  end
end
