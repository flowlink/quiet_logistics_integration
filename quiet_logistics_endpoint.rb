require 'sinatra'
require 'endpoint_base'
require 'json'
require 'honeybadger'

Dir['./lib/**/*.rb'].each { |f| require f }

class QuietLogisticsEndpoint < EndpointBase::Sinatra::Base

  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/**/*.*'
  end

  set :logging, true

  set(:method) do |method|
    method = method.to_s.upcase
    condition { request.request_method == method }
  end

  before :method => :post do
    Aws.config.update({
      region: @config['amazon_region'],
      credentials: Aws::Credentials.new(
        @config['amazon_access_key'],
        @config['amazon_secret_key']
      )
    })
  end

  post '/get_messages' do
    begin
      queue = @config['ql_incoming_queue']

      message_count = 0
      receiver = Receiver.new(queue, @config['ql_message_iterations'])
      receiver.receive_messages do |msg|
        if Messages::MessageParser.is_regexp_match?(msg, @config)
          if @config['ql_include_timestamp']
            message = msg.merge({ timestamp: Time.now.to_s })
          else
            message = msg
          end
          add_object :message, message
          message_count += 1
        end
      end

      message  = "Received #{message_count} message(s)"
      code     = 200
    rescue => e
      log_if_dev(e)
      message  = e.message
      code     = 500
    end

    result code, message
  end

  post '/get_data' do
    begin
      bucket = @config['ql_incoming_bucket']
      msg    = @payload['message']
      data   = Processor.new(bucket).process_doc(msg)

      if data.type == :unknown
        message = "Cannot handle document of type #{msg['document_type']}"
      else
        add_object(data.type.to_sym, data.to_h)
        message  = "Got Data for #{msg['document_name']}"
      end

      code = 200
    rescue => e
      log_if_dev(e)
      message  = e.message
      code     = 500
    end

    result code, message
  end

  post '/add_shipment' do
    begin
      shipment = @payload['shipment'] || @payload['order']
      message  = Api.send_document('ShipmentOrder', shipment, outgoing_bucket, outgoing_queue, @config)

      if shipment['return_to_flowlink']
        add_object(
          :shipment,
          {
            id: shipment['id']
          }.merge(
            shipment['return_to_flowlink']
          )
        )
      end

      code     = 200
    rescue => e
      log_if_dev(e)
      message = e.message
      code    = 500
    end

    result code, message
  end

  post '/add_purchase_order' do
    begin
      order   = @payload['purchase_order']
      message = Api.send_document('PurchaseOrder', order, outgoing_bucket, outgoing_queue, @config)
      code    = 200
    rescue => e
      log_if_dev(e)
      message = e.message
      code    = 500
    end

    result code, message
  end

  post '/cancel_shipment_order' do
    begin
      order   = @payload['order']
      message = Api.send_document('ShipmentOrderCancel', order, outgoing_bucket, outgoing_queue, @config)
      code    = 200
    rescue => e
      log_if_dev(e)
      message = e.message
      code    = 500
    end

    result code, message
  end

  post '/add_inventory_summary_request' do
    begin
      inventory   = {}
      message = Api.send_document('InventorySummaryRequest', inventory, outgoing_bucket, outgoing_queue, @config)
      code    = 200
    rescue => e
      log_if_dev(e)
      message = e.message
      code    = 500
    end

    result code, message
  end

  post '/add_product' do
    begin
      item    = @payload['product']
      message = Api.send_document('ItemProfile', item, outgoing_bucket, outgoing_queue, @config)
      code    = 200
    rescue => e
      log_if_dev(e)
      message = e.message
      code    = 500
    end

    result code, message
  end

  post '/add_rma' do
    begin
      shipment = @payload['rma']
      message  = Api.send_document('RMADocument', shipment, outgoing_bucket, outgoing_queue, @config)
      code     = 200
    rescue => e
      log_if_dev(e)
      message  = e.message
      code     = 500
    end

    result code, message
  end

  post '/get_shipments' do
    begin
      bucket = @config['ql_incoming_bucket']
      msg    = @payload['message']
      type   = msg['document_type']

      if type == 'ShipmentOrderResult'
        data   = Processor.new(bucket).process_doc(msg)
        add_object(data.type.to_sym, data.to_flowlink_hash)
        message  = "Got Shipment for #{msg['document_name']}"
      end

      unless @config['delete_message'] == '0' || @config['delete_message'] == 0
        MessageDeleter.new(@config, @payload).delete_message if msg['receipt_handle']
      end

      code = 200
    rescue => e
      log_if_dev(e)
      message  = e.message
      code     = 500
    end

    result code, message
  end

  post '/get_inventory_summary' do
    begin
      bucket = @config['ql_incoming_bucket']
      msg    = @payload['message']
      type   = msg['document_type']

      if type == 'InventorySummaryReady'
        data   = Processor.new(bucket).process_doc(msg)
        data.to_flowlink_hash.each do |item|
          add_object(data.type.to_sym, item)
        end
        message  = "Got inventory for #{msg['document_name']}"
      end

      unless @config['delete_message'] == '0' || @config['delete_message'] == 0
        MessageDeleter.new(@config, @payload).delete_message if msg['receipt_handle']
      end

      code = 200
    rescue => e
      log_if_dev(e)
      message  = e.message
      code     = 500
    end

    result code, message
  end

  post '/get_shipment_cancellations' do
    begin
      bucket = @config['ql_incoming_bucket']
      msg    = @payload['message']
      type   = msg['document_type']

      if type == 'ShipmentOrderCancelReady'
        data   = Processor.new(bucket, @config).process_doc(msg)
        add_object(data.type.to_sym, data.to_flowlink_hash)
        message  = "Got Shipment Cancellation for #{msg['document_name']}"
      end

      unless @config['delete_message'] == '0' || @config['delete_message'] == 0
        MessageDeleter.new(@config, @payload).delete_message if msg['receipt_handle']
      end

      code = 200
    rescue => e
      log_if_dev(e)
      message  = e.message
      code     = 500
    end

    result code, message
  end

  post '/get_errors' do
    begin
      receipt_handles = []
      message = ""
      code = 206

      unless delete_error_messages?
        receipt_handles_to_delete.each do |handle|
          error_payload = {'message' => { 'receipt_handle' => handle.strip} }
          MessageDeleter.new(@config, error_payload).delete_message
        end
      else
        queue = @config['ql_incoming_queue']
        receiver = Receiver.new(queue, @config['ql_message_iterations'])
        receiver.receive_errors do |msg|
          receipt_handles << msg[:receipt_handle]
          add_object :error_message, msg
        end

        message = "Received #{receiver.count} error messages"
        code = 200
      end

      add_parameter 'receipt_handles_to_delete', receipt_handles.to_json
    rescue => e
      log_if_dev(e)
      message  = e.message
      code     = 500
    end

    result code, message
  end

  post '/get_returns' do
    begin
      bucket = @config['ql_incoming_bucket']
      msg    = @payload['message']
      type   = msg['document_type']

      if type == 'RMAResultDocument'
        data   = Processor.new(bucket).process_doc(msg)
        add_object(:returns, data.to_flowlink_hash)
        message  = "Got RMAResult for #{msg['document_name']}"
      end

      unless @config['delete_message'] == '0' || @config['delete_message'] == 0
        MessageDeleter.new(@config, @payload).delete_message if msg['receipt_handle']
      end

      code = 200
    rescue => e
      log_if_dev(e)
      message  = e.message
      code     = 500
    end

    result code, message
  end

  def outgoing_queue
    @config['ql_outgoing_queue']
  end

  def outgoing_bucket
    @config['ql_outgoing_bucket']
  end

  def receipt_handles_to_delete
    # Adds this check here for backwards compatibility in case someone forgets
    # to add this param in an existing workflow in FlowLink
    handles = @config['receipt_handles_to_delete'] || "[]"
    @receipt_handles_to_delete ||= JSON.parse(handles)
  end

  def delete_error_messages?
    receipt_handles_to_delete.empty? ||
    @config['delete_message'] == '0' ||
    @config['delete_message'] == 0
  end

  def log_if_dev(e)
    return unless ENV['RAILS_ENV'] = "development"
    puts e.backtrace
  end
end
