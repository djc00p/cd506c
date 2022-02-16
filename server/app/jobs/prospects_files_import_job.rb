require 'csv'

class ProspectsFilesImportJob < ApplicationJob
  include TmpImportFile # lib/modules/tmp_import_file.rb
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  retry_on Net::OpenTimeout,
           Timeout::Error, wait: :exponentially_longer, attempts: 10
           
  queue_as :default

  around_perform do |job, block|
    # Send an email to user that the file being processed
    block.call
    # Send an email to user that the file has been processed
  end

  def perform(pf_import)
    pf_data = pf_import.file.download

    pf_import.csv_import(pf_data)
    delete_tmp(tmp_file_path(pf_data))
  end
end
