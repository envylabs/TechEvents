class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :user_id
      t.string :name
      t.text :description
      t.string :link
      t.datetime :start_time
      t.datetime :end_time
      t.string :latitude
      t.string :longitude
      t.string :human_address
      t.boolean :newsletter

      t.timestamps
    end
  end
end
