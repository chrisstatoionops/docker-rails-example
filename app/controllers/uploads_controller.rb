class UploadsController < ApplicationController
  def index
    @uploads = Upload.with_attached_file.order(created_at: :desc)
    @upload = Upload.new
  end

  def create
    @upload = Upload.new(upload_params)
    if @upload.save
      redirect_to uploads_path, notice: "File uploaded."
    else
      @uploads = Upload.with_attached_file.order(created_at: :desc)
      flash.now[:alert] = @upload.errors.full_messages.to_sentence.presence || "Upload failed."
      render :index, status: :unprocessable_entity
    end
  end

  def show
    upload = Upload.find(params[:id])
    unless upload.file.attached?
      head :not_found
      return
    end

    redirect_to rails_blob_path(upload.file, disposition: "attachment")
  end

  def destroy
    upload = Upload.find(params[:id])
    upload.destroy!
    redirect_to uploads_path, notice: "File deleted."
  rescue ActiveRecord::RecordNotFound
    redirect_to uploads_path, alert: "Upload not found.", status: :see_other
  end

  private

  def upload_params
    params.require(:upload).permit(:file)
  end
end
