class AddPostToSocialAtToEvents < ActiveRecord::Migration
  def change
    add_column :events, :post_to_social_at, :datetime
  end
end
