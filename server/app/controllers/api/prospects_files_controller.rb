class Api::ProspectsFilesController < ApplicationController
  before_action :file_length_validation, only: [:import]

  def import
    pf_import = ProspectsFiles.new({
      **prospects_files_params,
      user_id: @user.id})
    pf_import[:file] = prospects_files_params[:file].original_filename

    if pf_import.save
      ProspectsFilesImportJob.perform_later(pf_import)

      render json: { message: "Thank you! Your file is being processed now."}
    else
      render json: { error: "File unable to be processed",
                     status: :unprocessable_entity }
    end
  end

  def progress
    pf_import = ProspectsFiles.find(params[:id])
    total = pf_import.row_count
    done =  pf_import.done

    if pf_import.present?
      render json: { total: total, done: done }
    else
      render json: { error: "File not found" }, status: :not_found
    end
  end

  private

  def prospects_files_params
    params.permit(:file, :email_index, :first_name_index?,:last_name_index?, :force?, :has_headers?)
  end

  def file_length_validation
    hh = ActiveRecord::Type::Boolean.new.cast(params[:has_headers?])
    file_length = CSV.read(params[:file], headers: hh).count
    if file_length > 1000000
      errors[:file] << "should be less than 1,000,000 rows"
    end
  end
end
