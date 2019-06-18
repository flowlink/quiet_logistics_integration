require 'spec_helper'

module Documents
  describe ShipmentOrderResult do

    it 'should convert a document to a hash' do
      xml = <<-XML
        <?xml version="1.0" encoding="utf-8"?>
        <SOResult
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            ClientID="BONOBOS"
            BusinessUnit="BONOBOS" OrderNumber="H13088556647"
            DateShipped="2015-02-24T15:51:31.0953088Z"
            FreightCost="0"
            CartonCount="1"
            Warehouse="DVN"
            xmlns="http://schemas.quiettechnology.com/V2/SOResultDocument.xsd">
          <Line Line="1" ItemNumber="1111111" Quantity="1" ExceptionCode="" Tax="0" Total="0" SubstitutedItem="" />
          <Line Line="2" ItemNumber="2222222" Quantity="1" ExceptionCode="" Tax="0" Total="0" SubstitutedItem="" />
          <Line Line="3" ItemNumber="3333333" Quantity="1" ExceptionCode="" Tax="0" Total="0" SubstitutedItem="" />
          <Carton
              CartonId="S11111111"
              TrackingId="1Z1111111111111111"
              Carrier="UPS"
              CartonNumber="1"
              ServiceLevel="GROUND"
              Weight="1.11"
              FreightCost="11.11"
              HandlingFee="0"
              Surcharge="0"
              PackageType="SINGLE">
            <Content Line="1" ItemNumber="1111111" Quantity="1" />
            <Content Line="2" ItemNumber="2222222" Quantity="1" />
          </Carton>
          <Carton
              CartonId="S22222222"
              TrackingId="1Z2222222222222222"
              Carrier="UPS"
              CartonNumber="1"
              ServiceLevel="GROUND"
              Weight="2.22"
              FreightCost="22.22"
              HandlingFee="0"
              Surcharge="0"
              PackageType="LARGE1">
            <Content Line="3" ItemNumber="3333333" Quantity="1" />
          </Carton>
          <Extension />
        </SOResult>
      XML

      result = ShipmentOrderResult.new(xml)

      expect(result.to_flowlink_hash).to eq(
        :id => "H13088556647",
        :tracking => "1Z1111111111111111",
        :warehouse => "DVN",
        :status => "shipped",
        :business_unit => "BONOBOS",
        :shipped_at => "2015-02-24T15:51:31.0953088Z",
        :cartons => [
          {
            :id => "S11111111",
            :tracking => "1Z1111111111111111",
            :line_items => [
              {
                :ql_item_number => "1111111",
                :quantity => 1,
              },
              {
                :ql_item_number => "2222222",
                :quantity => 1,
              },
            ],
          },
          {
            :id => "S22222222",
            :tracking => "1Z2222222222222222",
            :line_items => [
              {
                :ql_item_number => "3333333",
                :quantity => 1,
              },
            ],
          },
        ],
      )
    end
  end
end
