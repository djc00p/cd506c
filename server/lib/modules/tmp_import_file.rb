module TmpImportFile
  def tmp_file_path(file)
    file_path = Rails.root.join('tmp', 'csv_file.csv')
    File.open(file_path, 'w') do |tmp_file|
      tmp_file.write(file)
    end
    file_path
  end

  def delete_tmp(tmp_file)
      File.delete(tmp_file) if File.exist?(tmp_file)
  end
end
