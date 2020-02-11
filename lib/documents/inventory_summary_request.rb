# frozen_string_literal: true

module Documents
  class InventorySummaryRequest
    attr_reader :name, :unit

    def initialize(object, config)
      @config         = config
      @name           = "#{@config['business_unit']}_InventorySummaryRequest_#{date_stamp}.xml"
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.InventorySummaryRequest(
          'xmlns' => 'http://schemas.quietlogistics.com/V2/InventorySummaryRequest.xsd',
          'ClientId' => @config['client_id'],
          'BusinessUnit' => @config['business_unit']
          ){}
      end
      builder.to_xml
    end

    def message
      'Succesfully Sent Inventory Summary Request to QL'
    end

    def date_stamp
      Time.now.strftime('%Y%m%d_%H%M%3N')
    end
  end
end
