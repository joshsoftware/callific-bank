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
end
