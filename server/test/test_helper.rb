ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  set_fixture_class prospects_files: ProspectsFiles
  fixtures :all

  # Add more helper methods to be used by all tests here...
  parallelize_teardown do |i|
    FileUtils.rm_rf(ActiveStorage::Blob.services.fetch(:test_fixtures).root)
  end
end
