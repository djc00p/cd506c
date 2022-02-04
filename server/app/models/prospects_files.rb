class ProspectsFiles < ApplicationRecord
  has_one_attached :file
  belongs_to :user
end
