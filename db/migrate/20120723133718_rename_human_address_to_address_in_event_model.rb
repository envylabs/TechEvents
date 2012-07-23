class RenameHumanAddressToAddressInEventModel < ActiveRecord::Migration
	def change
		rename_column :events, :human_address, :address
	end
end
