require 'csv'

class ProspectsFilesImportJob < ApplicationJob
  retry_on Net::OpenTimeout,
           Timeout::Error, wait: :exponentially_longer, attempts: 10

  queue_as :default

  around_perform do |job, block|
    block.call
  end

  def perform(prospect_file)
    prospect_file_attachment = prospect_file.file

    prospect_file.csv_import(prospect_file_attachment)
  end
end
