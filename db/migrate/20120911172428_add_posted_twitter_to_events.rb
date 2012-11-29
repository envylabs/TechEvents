class AddPostedTwitterToEvents < ActiveRecord::Migration
  def change
    add_column :events, :posted_twitter, :boolean
  end
end
