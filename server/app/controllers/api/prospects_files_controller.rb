class Api::ProspectsFilesController < ApplicationController
  def import
    pf_import = ProspectsFiles.new({
      **prospects_files_params,
      user_id: @user.id })
    pf_import[:file] = prospects_files_params[:file].original_filename

    if pf_import.save
      ProspectsFilesImportJob.perform_later(pf_import.id)

      render json: { message: "Thank you! Your file is being processed now."}
    else
      render json: { error: "File unable to be processed", status: :unprocessable_entity }
    end
  end

  private

  def prospects_files_params
    params.permit(:file, :email_index, :first_name_index?,:last_name_index?, :force?, :has_headers?)
  end
end
