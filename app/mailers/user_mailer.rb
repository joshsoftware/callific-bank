class UserMailer < ApplicationMailer
  default from: "pankaj@joshsoftware.com"
  layout false

  def send_dealer_data_upload_status(file_path, user_email)
    mail.attachments['Latest Corrected RTO Sheet.xlsx'] = File.read(file_path)
    mail(
      to: user_email, subject: "Dealer Data Uploaded",
      cc: 'pankaj@joshsoftware.com'
      )
  end

  def send_rto_data_upload_status(file_path, user_email, upload_count, err_count)
    @upload_count = upload_count
    @err_count = err_count
    
    mail.attachments[
      'Latest Error File.xlsx'
      ] = File.read(file_path) if File.exists?(file_path)
    
    mail(
      to: user_email, subject: "RTO Data Uploaded",
      cc: 'pankaj@joshsoftware.com'
      )
  end
end
