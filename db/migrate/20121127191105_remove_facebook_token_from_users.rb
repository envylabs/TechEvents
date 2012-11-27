class RemoveFacebookTokenFromUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :facebook_token
  end
end
