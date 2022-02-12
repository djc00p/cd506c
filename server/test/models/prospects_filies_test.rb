require "test_helper"

class ProspectsFilesTest < ActiveSupport::TestCase
  should validate_attached_of(:file)
  should validate_content_type_of(:file).allowing('text/csv')
  
end
