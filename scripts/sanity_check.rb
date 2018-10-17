require 'aws-sdk'

Aws.config.update({
  region: 'us-east-1',
  credentials: Aws::Credentials.new(ENV['QL_ACCESS_KEY_ID'], ENV['QL_SECRET_ACCESS_KEY'])
})

puts "Buckets:"
s3 = Aws::S3::Resource.new
s3.buckets.limit(50).each do |b|
  puts "#{b.name}"
  b.objects.each do |obj|
    puts '  ' + obj.key
  end
end

puts "\nQueues:"
sqs = Aws::SQS::Resource.new
sqs.queues.each do |q|
  puts "#{q.url}"
  msgs = q.receive_messages({max_number_of_messages: 10, attribute_names: ["All"]})
  msgs.each do |sqs_message|
    puts "  #{sqs_message.to_s}"
  end
end
