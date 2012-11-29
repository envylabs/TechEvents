class UpdateLatitudeLongitudeLimit < ActiveRecord::Migration
  def change
  	change_column :events, :latitude, :float, :limit => 16
  	change_column :events, :longitude, :float, :limit => 16
  end
end
