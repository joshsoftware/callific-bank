require 'csv'

class DashboardUploadJob < ActiveJob::Base
  include CommonMethods
  queue_as :default

  def perform(file_path, upload_type, user_email)
    begin
      case upload_type
      when 'rto'
        rto_sheet_upload(file_path, user_email)
      when 'dealer'
        dealer_sheet_upload(file_path, user_email)
      end
    ensure 
      clear_job_from_redis(upload_type)
    end
  end

  def clear_job_from_redis(upload_type)
    REDIS_CLIENT.del("#{upload_type}_jobs")
  end

  def rto_sheet_upload(file_path, user_email)
    rto_file = File.open(file_path, 'r')
    upload_obj = RtoUpload.new(file_path, user_email)
    upload_obj.import_rto_data(rto_file)
  end

  def dealer_sheet_upload(file_path, user_email)
    upload_obj = DealerUpload.new(file_path, user_email)
    upload_obj.import_dealer_data
  end

end
