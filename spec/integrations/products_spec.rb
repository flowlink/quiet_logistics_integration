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

  # TODO: Fix AWS with VCR error
  # Currently getting AWS error with VCR:
  #   MD5 returned by SQS does not match the calculation on the original request
  # Tried `Aws.config[:verify_checksums] = false` but still erroring

  xdescribe "add_product", vcr: { record: :new_episodes } do
    it "returns 200" do
      product = {
        "id": "10101010101010101",
        "name": "Name",
        "sku": "10101010101010101",
        "description": "Description field",
        "price": 24.0,
        "quantity": 8
      }

      post '/add_product', {
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
        product: product,
        "request_id": "5b8c6c82-090d-46d1-8a4a-3cc14e33485e"
      }.to_json, headers

      response = JSON.parse(last_response.body)

      expect(last_response.status).to eq 200
      expect(response).to have_key "summary"
      expect(response["summary"]).to be_instance_of(String)

    end

  end

end
