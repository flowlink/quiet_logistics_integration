class Uploader
  def initialize(bucket)
    @bucket = bucket
  end

  def process(name, xml)
    #file = StringIO.new(xml)
    upload(name, xml)
  end

  private
  def upload(name, xml)
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(@bucket)

    s3_object = bucket.object(name)
    s3_object.put(body: xml)

    s3_object.public_url
  end
end