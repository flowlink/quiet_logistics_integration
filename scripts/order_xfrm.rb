require 'json'
require 'date'
payload = JSON.parse(File.read('sample_order.json'), :symbolize_names => true)
result = {}

carrier = 'USPS'
service_level = 'First'
case payload[:shipping_method]
when 'Expedited (2-3 Business Days)'
  carrier = 'FEDEX'
  service_level = '2DAY'
when 'Overnight'
  carrier = 'FEDEX'
  service_level = '1DAY'
end

shipment = {
    id: payload[:id],
    order_number: payload[:id],
    carrier: carrier,
    service_level: service_level,
    order_type: "SO",
    comments: "No comments",
    items: []
}

# each_with_index not allowed in sandbox, so ...
index = 0
payload[:line_items].each do |item|
  shipment[:items][index] = {
      line_number: index + 1,
      quantity: item[:quantity],
      sku: item[:product_id],
      price: item[:price]
  }
  index = index + 1
end

shipment[:shipping_address] = {
    firstname: payload[:shipping_address][:firstname],
    lastname: payload[:shipping_address][:lastname],
    address1: payload[:shipping_address][:address1],
    address2: payload[:shipping_address][:address2],
    city: payload[:shipping_address][:city],
    zipcode: payload[:shipping_address][:zipcode],
    country: payload[:shipping_address][:country],
    state: payload[:shipping_address][:state]
}

shipment[:billing_address] = {
    firstname: payload[:billing_address][:firstname],
    lastname: payload[:billing_address][:lastname],
    address1: payload[:billing_address][:address1],
    address2: payload[:billing_address][:address2],
    city: payload[:billing_address][:city],
    zipcode: payload[:billing_address][:zipcode],
    country: payload[:billing_address][:country],
    state: payload[:billing_address][:state]
}


result[:order] = shipment

puts shipment.to_json
