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

    def initialize(xml, config)
      @doc = Nokogiri::XML(xml)
      @type = :order
      @config = config
    end

    def to_flowlink_hash
      return unless @doc.xpath('//@Status').first.text == "SUCCESS"


      id = @doc.xpath('//@OrderNumber').first.text
      data = {
        id: id,
        quietlogistics_id: id,
        order_number: @doc.xpath('//@OrderNumber').first.text,
        # NOTE: There may multiple tracking numbers. This is just the first.
        warehouse: @doc.xpath('//@Warehouse').first.text,
        status: 'cancelled',
        reason: @doc.xpath('//@Reason').first.text,
        business_unit: @doc.xpath('//@BusinessUnit').first.value
      }

      if @config['ql_keys']
        keys = @config['ql_keys'].split(',')
        data[:key] = @config['ql_keys']
        keys.each { |key| data[key] = id }
      end

      data
    end
  end
end
