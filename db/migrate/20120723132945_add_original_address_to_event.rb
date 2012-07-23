class AddOriginalAddressToEvent < ActiveRecord::Migration
  def change
    add_column :events, :original_address, :string
  end
end
