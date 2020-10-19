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
  class InventorySummaryReady
    NAMESPACE = 'http://schemas.quietlogistics.com/V2/InventorySummary.xsd'

    attr_reader :type

    def initialize(xml)
      @doc = Nokogiri::XML(xml)
      @type = :inventory
    end

    def to_flowlink_hash
      inventories = []

      summary = @doc.xpath('ql:InventorySummary', 'ql' => NAMESPACE )

      items = @doc.xpath('ql:InventorySummary/ql:Inventory', 'ql' => NAMESPACE)

      items.map do |item|
        statuses = item.xpath('ql:ItemStatus', 'ql' => NAMESPACE)
        inventory = {
          id: "#{item['ItemNumber']}",
          product_id: item['ItemNumber'],
          location: summary.first['Warehouse'],
          updated_at: Time.now.strftime('%Y%m%d_%H%M%3N')
        }

        statuses.each do |status|
          inventory[:quantity] = status['Quantity'].to_i if status['Status'] == 'Avail'
          inventory[:allocated_quantity] = status['Quantity'].to_i if status['Status'] == 'Alloc'
          inventory[:received_quantity] = status['Quantity'].to_i if status['Status'] == 'RECEIVED'
        end

        inventories << inventory

      end

      inventories
    end
  end
end
