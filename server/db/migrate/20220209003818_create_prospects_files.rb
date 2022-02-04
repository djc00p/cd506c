class CreateProspectsFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :prospects_files do |t|
      t.string :file
      t.integer :email_index
      t.integer :first_name_index?
      t.integer :last_name_index?
      t.boolean :force?
      t.boolean :has_headers?

      t.timestamps
    end
  end
end
