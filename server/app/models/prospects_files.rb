class ProspectsFiles < ApplicationRecord
  include TmpImportFile # lib/modules/tmp_import_file.rb

  has_one_attached :file
  belongs_to :user
  has_many :prospects
  validates_presence_of :email_index
  validates :file,
            attached: true,
            content_type: { in: 'text/csv', message: 'Not a CSV File' },
            size: { less_than_or_equal_to: 200.megabytes, message: 'file to big'}

  def row_count
    total_rows = CSV.foreach(
      tmp_file_path(self.file.download),
      headers: self.has_headers?
    ).count

    delete_tmp(tmp_file_path(self.file.download))
    total_rows
  end

  def done
    time = Time.zone.now

    Prospect.where(user_id: self.user_id)
            .where(created_at: self.created_at..time)
            .where(updated_at: self.created_at..time)
            .count
  end

  def csv_import(pf_data)
    CSV.foreach(tmp_file_path(pf_data), headers: self.has_headers?) do |row|
      email = headers?(row.to_a[self.email_index])
      first_name = headers?(row.to_a[self.first_name_index?])
      last_name = headers?(row.to_a[self.last_name_index?])
      user_id = self.user_id

      force_check(self.force?, email, first_name, last_name, user_id)
    end
  end

  def force_check(force, email, first_name, last_name, user_id)
    if force
      force(email, first_name, last_name, user_id)
    else
      create_prospect(email, first_name, last_name, user_id)
    end
  end

  def force(email, first_name, last_name, user_id)
    if Prospect.exists?(email: email)
      update_prospect(email, first_name, last_name, user_id)
    else
      create_prospect(email, first_name, last_name, user_id)
    end
  end

  def create_prospect(email, first_name, last_name, user_id)
    Prospect.create!(
      email: email,
      first_name: first_name,
      last_name: last_name,
      user_id: user_id
    )
  end

  def update_prospect(email, first_name, last_name, user_id)
    Prospect.update_all(
      email: email,
      first_name: first_name,
      last_name: last_name,
      user_id: user_id
    )
  end

  def headers?(a)
    if a.kind_of?(Array)
      a[1]
    else
      a
    end
  end
end
