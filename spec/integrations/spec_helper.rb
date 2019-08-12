require 'rack/test'
require 'rubygems'
require 'bundler'
require 'vcr'
Bundler.require(:default, :test)
# require File.join(File.dirname(__FILE__), '..', '../lib/qb_integration.rb')
require File.join(File.dirname(__FILE__), '..', '../quiet_logistics_endpoint')

VCR.configure do |c|
  c.cassette_library_dir = "spec/vcr"
  c.hook_into :webmock
  c.filter_sensitive_data('<client_id>') { ENV.fetch('client_id') }
  c.filter_sensitive_data('<amazon_region>') { ENV.fetch('amazon_region') }
  c.filter_sensitive_data('<business_unit>') { ENV.fetch('business_unit') }
  c.filter_sensitive_data('<amazone_access_key>') { ENV.fetch('amazon_access_key') }
  c.filter_sensitive_data('<amazone_secret_key>') { ENV.fetch('amazon_secret_key') }
  c.filter_sensitive_data('<ql_incoming_queue>') { ENV.fetch('ql_incoming_queue') }
  c.filter_sensitive_data('<ql_outgoing_queue>') { ENV.fetch('ql_outgoing_queue') }
  c.filter_sensitive_data('<ql_incoming_bucket>') { ENV.fetch('ql_incoming_bucket') }
  c.filter_sensitive_data('<ql_outgoing_bucket>') { ENV.fetch('ql_outgoing_bucket') }
  c.configure_rspec_metadata!
end
