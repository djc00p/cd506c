class AddTotalRowsToProspectsFiles < ActiveRecord::Migration[6.1]
  def change
    add_column :prospects_files, :total_rows, :integer
  end
end
