#
# A ShipmentOrderResult lists items shipped, tracking number, carrier
# information, and packaging details.
#
# The structure of the XML document is:
#
=begin
  <SOResult ...>
    <Line ... />
    <Line ... />
    <Line ... />
    <Carton ... >
      <Content ... />
      <Content ... />
    </Carton>
    <Carton ... >
      <Content ... />
    </Carton>
    <Extension />
  </SOResult>
=end
#
# See the specs for a full example.

module Documents
  class ShipmentOrderResult
    NAMESPACE = 'http://schemas.quiettechnology.com/V2/SOResultDocument.xsd'

    attr_reader :type

    def initialize(xml)
      @doc = Nokogiri::XML(xml)
      @type = :shipment
      @shipment_number = @doc.xpath("//@OrderNumber").first.text
      @date_shipped = @doc.xpath("//@DateShipped").first.text
      @freight_cost = @doc.xpath("//@FreightCost").first.text
      @carton_count = @doc.xpath("//@CartonCount").first.text
      @tracking_number = @doc.xpath('//@TrackingId').first.value
      @business_unit = @doc.xpath('//@BusinessUnit').first.value
      @warehouse = @doc.xpath("//@Warehouse").first.text
      @carrier = @doc.xpath("//@Carrier").first.text
      @service_level = @doc.xpath("//@ServiceLevel").first.text
      @shipping_method = @carrier + ' ' + @service_level
    end

    def to_h
      {
        id: @shipment_number,
        # NOTE: There may multiple tracking numbers. This is just the first.
        tracking: @tracking_number,
        shipping_method: @shipping_method,
        warehouse: @warehouse,
        status: 'shipped',
        business_unit: @business_unit,
        shipped_at: @date_shipped,
        cartons: cartons_to_h,
      }
    end

    private

    def cartons_to_h
      cartons = @doc.xpath('ql:SOResult/ql:Carton', 'ql' => NAMESPACE)
      cartons.map do |carton|
        {
          :id => carton['CartonId'],
          :tracking => carton['TrackingId'],
          :line_items => carton_line_items_to_h(carton),
        }
      end
    end

    def carton_line_items_to_h(carton)
      contents = carton.xpath('ql:Content', 'ql' => NAMESPACE)
      contents.map do |content|
        {
          :ql_item_number => content['ItemNumber'],
          :quantity => Integer(content['Quantity']),
        }
      end
    end

  end
end

