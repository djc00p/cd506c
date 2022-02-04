require 'csv'
class ProspectsFilesImportJob < ApplicationJob

  queue_as :default

  def perform(pf_import_id)
    pf_import = ProspectsFiles.find(pf_import_id)
    tmp_file_path = Rails.root.join('tmp', 'csv_file.csv')
    pf_data = pf_import.file.download

    File.open(tmp_file_path, 'w') do |file|
      file.write(pf_data)
    end
    CSV.foreach(tmp_file_path, headers: pf_import.has_headers?) do |row|

      email = has_headers?(row.to_a[pf_import.email_index])
      first_name = has_headers?(row.to_a[pf_import.first_name_index?])
      last_name = has_headers?(row.to_a[pf_import.last_name_index?])
      user_id = pf_import.user_id
      
      if pf_import.force?
        if Prospect.exists?(email: email)
          update_prospect(email,first_name,last_name,user_id)
        else
          create_prospect(email,first_name,last_name,user_id)
        end
      else
        create_prospect(email,first_name,last_name,user_id)
      end
    end
    File.delete(tmp_file_path) if File.exist?(tmp_file_path)
  end

  def create_prospect(email,first_name,last_name,user_id)
    Prospect.create!(
      email: email,
      first_name: first_name,
      last_name: last_name,
      user_id: user_id
    )
  end

  def update_prospect(email,first_name,last_name,user_id)

    Prospect.update_all(
      email: email,
      first_name: first_name,
      last_name: last_name,
      user_id: user_id
    )
  end

  def has_headers?(a)
    if a.kind_of?(Array)
      a[1]
    else
      a
    end
  end
end
