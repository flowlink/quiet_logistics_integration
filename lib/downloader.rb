class Downloader
  def initialize(bucket)
    @bucket = bucket
  end

  def download(file_name)
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(@bucket)
    object = bucket.object(file_name)

    buffer = StringIO.new("", 'w')
    object.read do |chunk|
      buffer << chunk
    end
    buffer.close

    buffer.string
  end

  def delete_file(name)
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(@bucket)
    object = bucket.object(name)
    object.delete

    return !object.exists?
  end
end
