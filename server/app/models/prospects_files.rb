class ProspectsFiles < ApplicationRecord
  has_one_attached :file
  belongs_to :user
  has_many :prospects
  validates_presence_of :email_index
  validates :file,
            attached: true,
            content_type: { in: 'text/csv', message: 'Not a CSV File' },
            size: { less_than_or_equal_to: 200.megabytes, message: 'file to big'}

  def csv_import(prospect_file)
    prospect_file.blob.open(tmpdir: Rails.root.join('tmp')) do |tmp_file|
      parse_tmp_csv_file(tmp_file)
    end
  end

  def parse_tmp_csv_file(file)
    CSV.foreach(file, headers: self.has_headers?) do |row|
      email = headers?(row.to_a[self.email_index])
      first_name = headers?(row.to_a[self.first_name_index?])
      last_name = headers?(row.to_a[self.last_name_index?])
      user_id = self.user_id
      prospects_file_id = self.id

      create_or_update_prospect(self.force?, email, first_name, last_name, user_id, prospects_file_id)
    end
  end

  def create_or_update_prospect(force, email, first_name, last_name, user_id, prospects_file_id)
    if force && Prospect.exists?(email: email, user_id: user_id)
      update_prospect(email, first_name, last_name, user_id, prospects_file_id)
    elsif force == false && Prospect.exists?(email: email, user_id: user_id)
    else
      create_prospect(email, first_name, last_name, user_id, prospects_file_id)
    end
  end

  def create_prospect(email, first_name, last_name, user_id, prospects_file_id)
    Prospect.create!(email: email, first_name: first_name, last_name: last_name, user_id: user_id, prospects_file_id: prospects_file_id)
  end

  def update_prospect(email, first_name, last_name, user_id, prospects_file_id)
    Prospect.update_all(email: email, first_name: first_name, last_name: last_name, user_id: user_id, prospects_file_id: prospects_file_id)
  end

  def headers?(attribute)
    if attribute.kind_of?(Array)
      attribute[1]
    else
      attribute
    end
  end
end
