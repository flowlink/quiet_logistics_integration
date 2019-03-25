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
  class ShipmentOrderCancelReady
    NAMESPACE = 'http://schemas.quietlogistics.com/V2/SOCancelResultDocument.xsd'

    attr_reader :type

    def initialize(xml)
      @doc = Nokogiri::XML(xml)
      @type = :shipment
    end

    def to_flowlink_hash
      return unless @doc.xpath('//@Status').first.text == "SUCCESS"

      id = @doc.xpath('//@OrderNumber').first.text
      {
        id: id,
        quietlogistics_id: id,
        order_number: @doc.xpath('//@OrderNumber').first.text,
        # NOTE: There may multiple tracking numbers. This is just the first.
        warehouse: @doc.xpath('//@Warehouse').first.text,
        status: 'cancelled',
        reason: @doc.xpath('//@Reason').first.text,
        business_unit: @doc.xpath('//@BusinessUnit').first.value
      }
    end
  end
end
