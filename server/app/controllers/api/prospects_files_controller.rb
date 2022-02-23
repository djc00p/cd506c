class Api::ProspectsFilesController < ApplicationController
  before_action :file_length_validation, only: [:import]

  def import
    prospect_file = ProspectsFiles.new({
      **prospects_files_params,
      user_id: @user.id})
    prospect_file[:file] = prospects_files_params[:file].original_filename

    if prospect_file.save
      ProspectsFilesImportJob.perform_later(prospect_file)

      render json: { message: "Thank you! Your file is being processed now."}
    else
      render json: { error: prospect_file.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def progress
    prospect_file = ProspectsFiles.find_by(id: params[:id], user_id: @user.id)
    if prospect_file.present?
      total = prospect_file.total_rows
      done =  Prospect.where(user_id: @user.id, prospects_file_id: prospect_file.id).count
      
      render json: { total: total, done: done }
    else
      render json: { error: prospect_file.errors.full_messages }, status: :not_found
    end
  end

  private

  def prospects_files_params
    params.permit(:file, :email_index, :first_name_index?,:last_name_index?, :force?, :has_headers?, :total_rows)
  end

  def file_length_validation
    has_headers = ActiveRecord::Type::Boolean.new.cast(params[:has_headers?])
    file_length = CSV.read(params[:file], headers: has_headers).count
    if file_length > 1000000
      errors[:file] << "should be less than 1000000 rows"
    else
      params[:total_rows] = file_length
    end
  end
end
