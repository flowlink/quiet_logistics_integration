class Downloader
  def initialize(bucket)
    @bucket = bucket
  end

  def download(file_name)
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(@bucket)
    object = bucket.object(file_name)

    object.get.body.read
  end

  def delete_file(name)
    s3 = Aws::S3::Resource.new
    bucket = s3.bucket(@bucket)
    object = bucket.object(name)
    object.delete

    return !object.exists?
  end
end
