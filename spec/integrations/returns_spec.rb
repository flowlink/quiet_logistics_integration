require_relative 'spec_helper'

describe 'App' do
  let(:headers) {
    {
      "Content-Type": "application/json"
    }
  }
  let(:client_id) { ENV['client_id'] }
  let(:amazon_region) { ENV['amazon_region'] }
  let(:business_unit) { ENV['business_unit'] }
  let(:amazon_access_key) { ENV['amazon_access_key'] }
  let(:amazon_secret_key) { ENV['amazon_secret_key'] }
  let(:ql_incoming_queue) { ENV['ql_incoming_queue'] }
  let(:ql_outgoing_queue) { ENV['ql_outgoing_queue'] }
  let(:ql_incoming_bucket) { ENV['ql_incoming_bucket'] }
  let(:ql_outgoing_bucket) { ENV['ql_outgoing_bucket'] }

  include Rack::Test::Methods

  def app
    QuietLogisticsEndpoint
  end

  describe "add_return", vcr: { record: :new_episodes } do
    it "returns 200 and summary with id for default configs" do
      rma = {
        "id": 317,
        "rma_number": "RA000000317",
        "order_number": "428952",
        "tracking_number": "9202090198397801271468",
        "line_items": [
          "sku": "M02B04-FS-M",
          "quantity": 1
        ]
      }

      post '/add_rma', {
        "parameters": {
          "client_id": client_id,
          "amazon_region": amazon_region,
          "business_unit": business_unit,
          "amazon_access_key": amazon_access_key,
          "amazon_secret_key": amazon_secret_key,
          "ql_incoming_queue": ql_incoming_queue,
          "ql_outgoing_queue": ql_outgoing_queue,
          "ql_incoming_bucket": ql_incoming_bucket,
          "ql_outgoing_bucket": ql_outgoing_bucket
        },
        rma: rma,
        "request_id": "5b8c6c82-090d-46d1-8a4a-3cc14e33485e"
      }.to_json, headers

      response = JSON.parse(last_response.body)

      expect(last_response.status).to eq 200
      expect(response).to have_key "summary"
      expect(response["summary"]).to be_instance_of(String)

    end

  end

end
