class Admin::DashboardController < Admin::BaseController
  # GET /admin/social
  def index
  	settings = Settings.all
  	@twitter_account = settings[:user_id_for_twitter] ? User.find(settings[:user_id_for_twitter]).handle : nil
  	@facebook_account = settings[:user_id_for_facebook] ? User.find(settings[:user_id_for_facebook]).handle : nil
  end
end
