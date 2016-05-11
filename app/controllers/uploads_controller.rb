class UploadsController < ApplicationController
  before_filter :authenticate_user!, :except=>:index

  def index
    @uploads = Upload.all
  end

  def new
    @uploads = Upload.new
  end

  def create
    @uploads = Upload.new(uploads_params)

    if @uploads.save
      id = Mods2rdf::Converter.process(@uploads.attachment.read, @uploads.title_type, current_or_guest_user.user_key)
      @uploads.noid = id
      @uploads.save!
      redirect_to uploads_path, notice: "The MODS XML for #{@uploads.institution} has been uploaded."
    else
      render "new"
    end
  end

  def destroy
    @uploads = Upload.find(params[:id])
    @uploads.destroy
    redirect_to uploads_path, notice:  "The upload #{@uploads.institution} has been deleted."
  end


  def authenticate_user!
    if user_signed_in?
      super
    else
      redirect_to '/users/sign_in', :notice => 'Please sign in to do anything but view submissions'
      ## if you want render 404 page
      ## render :file => File.join(Rails.root, 'public/404'), :formats => [:html], :status => 404, :layout => false
    end
  end

  private
  def uploads_params
    params.require(:upload).permit(:institution, :title_type, :noid, :attachment)
  end
end
