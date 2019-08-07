require 'spec_helper'
require 'rspec'
require 'json'
require 'messages/message_parser'

RSpec.describe Messages::MessageParser do
  let(:basic_config) {
    {
      "amazon_region" => "us-east-1",
      "amazon_access_key" => "amazon_access_key",
      "amazon_secret_key" => "amazon_secret_key",
      "ql_incoming_bucket" => "ql_incoming_bucket",
      "ql_incoming_queue" => "ql_incoming_queue",
      "ql_outgoing_bucket" => "ql_outgoing_bucket",
      "ql_outgoing_queue" => "ql_outgoing_queue",
      "business_unit" => "business_unit",
      "client_id" => "client_id"
    }
  }
  let(:messages_from_ql) { JSON.parse(File.read('spec/fixtures/test_messages_from_ql.json')) }

  let(:single_regex_item) { "[{\"ShipmentOrderResult\":\"SoResultV2_TEST_[0-9]+_\"}]" }
  let(:two_regex_items) { "[{\"ShipmentOrderResult\":\"SoResultV2_TEST_[0-9]+_\",\"RMAResultDocument\":\"RmaResultV2_TEST_[0-9]+_\"}]" }
  let(:two_regex_items_matching_all) { "[{\"ShipmentOrderResult\":\".*\",\"RMAResultDocument\":\".*\"}]" }
  let(:two_regex_items_matching_none) { "[{\"ShipmentOrderResult\":\"SoResultV2_TEST_Z\",\"RMAResultDocument\":\"SoResultV2_TEST_Z\"}]" }
  
  let(:all_false_expectation) { [false, false, false, false]}
  let(:single_regex_expectation) { [false, true, false, false]}
  let(:two_regex_expectation) { [false, true, true, false]}
  let(:all_true_expectation) { [true, true, true, true]}

  describe "#is_regexp_match?" do

    it "has no regex param and it returns all messages" do
      answers = []
      messages_from_ql.each do |msg|
        answers << described_class.is_regexp_match?(msg, basic_config)
      end
      expect(answers).to eq(all_true_expectation)
    end

    it "has regex param with nothing set and it ignores an empty string and returns all messages" do
      basic_config["regex_items"] = ""
      answers = []
      messages_from_ql.each do |msg|
        answers << described_class.is_regexp_match?(msg, basic_config)
      end
      expect(answers).to eq(all_true_expectation)
    end

    it "has regex param with one item set and it only retrurns that item type that also matches the regex" do
      basic_config["regex_items"] = single_regex_item
      answers = []
      messages_from_ql.each do |msg|
        puts "NIL" if JSON.parse(basic_config['regex_items']).first[msg['document_type']]
        answers << described_class.is_regexp_match?(msg, basic_config)
      end
      expect(answers).to eq(single_regex_expectation)
    end

    it "has regex param with two items set and it only those items and only those that match the regex" do
      basic_config["regex_items"] = two_regex_items
      answers = []
      messages_from_ql.each do |msg|
        answers << described_class.is_regexp_match?(msg, basic_config)
      end
      expect(answers).to eq(two_regex_expectation)
    end

    it "has regex param with two items set to match all messages and it returns all of them" do
      basic_config["regex_items"] = two_regex_items_matching_all
      answers = []
      messages_from_ql.each do |msg|
        answers << described_class.is_regexp_match?(msg, basic_config)
      end
      expect(answers).to eq(all_true_expectation)
    end

    it "has regex param with two items set to match no messages and it returns none of them" do
      basic_config["regex_items"] = two_regex_items_matching_none
      answers = []
      messages_from_ql.each do |msg|
        answers << described_class.is_regexp_match?(msg, basic_config)
      end
      expect(answers).to eq(all_false_expectation)
    end
  end
end
