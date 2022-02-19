require 'csv'

class ProspectsFilesImportJob < ApplicationJob
  include TmpImportFile # lib/modules/tmp_import_file.rb
  retry_on ActiveRecord::Deadlocked, wait: 5.seconds, attempts: 3
  retry_on Net::OpenTimeout,
           Timeout::Error, wait: :exponentially_longer, attempts: 10

  queue_as :default

  around_perform do |job, block|
    block.call
  end

  def perform(prospect_file)
    prospect_file_data = prospect_file.file.download

    prospect_file.csv_import(prospect_file_data)
    delete_tmp(tmp_file_path(prospect_file_data))
  end
end
