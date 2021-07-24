require "zip"
require 'fileutils'
class DocumentsController < ApplicationController
  before_action :set_course
  before_action :set_document, only: %i[ show edit update destroy ]

  def show
  end

  # GET /documents/new
  def new
    @document = @course.documents.build
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents or /documents.json
  def create
    @document = @course.documents.build(document_params)

    respond_to do |format|
      if @document.save
        format.html { redirect_to @course, notice: "Document was successfully created." }
        format.json { render :show, status: :created, location: @document }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /documents/1 or /documents/1.json
  def update
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: "Document was successfully updated." }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1 or /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url, notice: "Document was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def download
    @courses = @course.documents.where(id: params[:document_ids])
    tmp_user_folder = "tmp/course_#{@course.id}"
    begin
      FileUtils.rm_rf(tmp_user_folder)
      File.delete("#{tmp_user_folder}.zip") if File.exist?("#{tmp_user_folder}.zip")
    rescue StandarError
    end


    directory_length_same_as_documents = Dir["#{tmp_user_folder}/*"].length == @courses.length
    FileUtils.mkdir_p(tmp_user_folder) unless Dir.exists?(tmp_user_folder)
    @courses.each do |document|
      filename = document.file.blob.filename.to_s
      create_tmp_folder_and_store_documents(document, tmp_user_folder, filename) unless directory_length_same_as_documents
      #---------- Convert to .zip --------------------------------------- #
      create_zip_from_tmp_folder(tmp_user_folder, filename) unless directory_length_same_as_documents
    end
    # Sends the *.zip file to be download to the client's browser
    send_file(Rails.root.join("#{tmp_user_folder}.zip"), :type => "application/zip",
                                                         :filename => "Files_for_#{@course.title.downcase.gsub(/\s+/, "_")}.zip", :disposition => "attachment")
  end

  private

  def create_tmp_folder_and_store_documents(document, tmp_user_folder, filename)
    File.open(File.join(tmp_user_folder, filename), "wb") do |file|
      # As per georgeclaghorn in comment ;)
      document.file.download { |chunk| file.write(chunk) }
    end
  end

  def create_zip_from_tmp_folder(tmp_user_folder, filename)
    Zip::File.open("#{tmp_user_folder}.zip", Zip::File::CREATE) do |zf|
      zf.add(filename, "#{tmp_user_folder}/#{filename}")
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_document
    @document = @course.documents.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def document_params
    params.require(:document).permit(:description, :course_id, :file)
  end
end
