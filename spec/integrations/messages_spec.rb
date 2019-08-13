
require_relative 'spec_helper'
require 'pp'

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

  describe "get_messages", vcr: true do
    it "returns 200 and summary with id for default configs" do
      post '/get_messages', {
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
        "request_id": "5b8c6c82-090d-46d1-8a4a-3cc14e33485e"
      }.to_json, headers

      response = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(response).to have_key "summary"
      expect(response["summary"]).to be_instance_of(String)
      expect(response["messages"].count).to eq 7

      first_msg = response["messages"].first
      expect(first_msg).to have_key("document_type")
      expect(first_msg).to have_key("document_name")
      expect(first_msg).to have_key("receipt_handle")
      expect(first_msg).to have_key("id")
      expect(first_msg).to have_key("message_date")
    end

  end

  describe "get_messages with regex_items", vcr: { record: :new_episodes } do
    it "returns 200 and summary with id for default configs" do
      post '/get_messages', {
        "parameters": {
          "client_id": client_id,
          "amazon_region": amazon_region,
          "business_unit": business_unit,
          "amazon_access_key": amazon_access_key,
          "amazon_secret_key": amazon_secret_key,
          "ql_incoming_queue": ql_incoming_queue,
          "ql_outgoing_queue": ql_outgoing_queue,
          "ql_incoming_bucket": ql_incoming_bucket,
          "ql_outgoing_bucket": ql_outgoing_bucket,
          "regex_items": "[{\"ShipmentOrderResult\":\".*\"}]"
        },
        "request_id": "5b8c6c82-090d-46d1-8a4a-3cc14e33485e"
      }.to_json, headers

      response = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(response).to have_key "summary"
      expect(response["summary"]).to be_instance_of(String)
      expect(response["messages"].count).to eq 6

    end

    it "returns 200 with prefix document name regex" do
      post '/get_messages', {
        "parameters": {
          "client_id": client_id,
          "amazon_region": amazon_region,
          "business_unit": business_unit,
          "amazon_access_key": amazon_access_key,
          "amazon_secret_key": amazon_secret_key,
          "ql_incoming_queue": ql_incoming_queue,
          "ql_outgoing_queue": ql_outgoing_queue,
          "ql_incoming_bucket": ql_incoming_bucket,
          "ql_outgoing_bucket": ql_outgoing_bucket,
          "regex_items": "[{\"ShipmentOrderResult\":\"SoResultV2_MACKWELDON_[0-9]+_\"}]"
        },
        "request_id": "5b8c6c82-090d-46d1-8a4a-3cc14e33485e"
      }.to_json, headers

      response = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(response).to have_key "summary"
      expect(response["summary"]).to be_instance_of(String)
      expect(response["messages"].count).to eq 4

    end

  end

  describe "get_shipments delete messages", vcr: true do
    it "returns 200 and shipments object" do
      post '/get_messages', {
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
        "request_id": "5b8c6c82-090d-46d1-8a4a-3cc14e33485e"
      }.to_json, headers

      response = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(response["summary"]).to be_instance_of(String)
      expect(response["messages"].count).to eq 7

      first_msg = response["messages"].first
      expect(first_msg).to have_key("document_type")
      expect(first_msg).to have_key("receipt_handle")
      expect(first_msg).to have_key("id")
      expect(first_msg).to have_key("message_date")
      expect(first_msg["document_type"]).to eq 'ShipmentOrderResult'

      post '/get_shipments', {
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
        "request_id": "5b8c6c82-090d-46d1-8a4a-3cc14e33485e",
        message: first_msg
      }.to_json, headers

      response = JSON.parse(last_response.body)
      expect(last_response.status).to eq 200
      expect(response["summary"]).to be_instance_of(String)
      expect(response).to have_key "shipments"

      post '/get_messages', {
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
        "request_id": "5b8c6c82-090d-46d1-8a4a-3cc14e33485e"
      }.to_json, headers

      response = JSON.parse(last_response.body)
      pp response
      expect(last_response.status).to eq 200
      expect(response["summary"]).to be_instance_of(String)
      expect(response["messages"].count).to eq 6

    end

  end

end
