class UpdateTokenInfoOnUsers < ActiveRecord::Migration
  def change
  	rename_column :users, :token, :twitter_token
  	add_column :users, :twitter_secret, :string
  	add_column :users, :facebook_token, :string
  end
end
