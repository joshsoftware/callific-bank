class DashboardController < ApplicationController
  before_filter :authenticate_user!
  include CommonMethods

  def index
  end

  def import
    file = params[:file]
    if file.present?
      unless find_if_job_present
        case params[:upload_type]
        when 'rto'
          rto_sheet_upload(file)
        when 'dealer'
          dealer_sheet_upload(file)
        end
      else
        flash[:alert] = 'Another Upload in progress'
      end
    else
      flash[:alert] = 'No File Uploaded'
    end
    redirect_to :back
  end

  private

  def rto_sheet_upload(file)
    upload_type = params[:upload_type]
    if check_file_extension(file)  
      job = DashboardUploadJob.perform_later(
        file.path, upload_type,
        current_user.email
      )
      flash[:notice] = 'Rto Sheet is being uploaded...'
    else
      delete_job_status
      flash[:alert] = "Unknown file type: #{file.original_filename}"
    end
  end

  def dealer_sheet_upload(file)
    upload_type = params[:upload_type]
    if check_file_extension(file)
      job = DashboardUploadJob.perform_later(
        file.path, upload_type,
        current_user.email
      )
      flash[:notice] = 'Dealer is being uploaded...'
    else
      delete_job_status
      flash[:alert] = "Unknown file type: #{file.original_filename}"
    end
  end

  def find_if_job_present
    job_present = REDIS_CLIENT.get(
      "#{params[:upload_type]}_jobs"
      ).present?
    
    unless job_present
      REDIS_CLIENT.set(
      "#{params[:upload_type]}_jobs",
      true
      )
    end

    job_present
    
  end

  def delete_job_status
    REDIS_CLIENT.del("#{params[:upload_type]}_jobs")
  end

end
