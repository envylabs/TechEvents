class AddAddressTbdToEvent < ActiveRecord::Migration
  def change
    add_column :events, :address_tbd, :boolean
  end
end
