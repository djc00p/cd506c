class Prospect < ApplicationRecord
  belongs_to :user
  belongs_to :prospects_files, optional: true
  has_and_belongs_to_many :campaigns
end
