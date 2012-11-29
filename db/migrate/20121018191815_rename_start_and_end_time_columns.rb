class RenameStartAndEndTimeColumns < ActiveRecord::Migration
  def change
  	rename_column :events, :start_time, :start_at
  	rename_column :events, :end_time, :end_at
  end
end
