class Admin::DashboardController < Admin::BaseController
  # GET /admin/social
  def index
  	settings = Settings.all
  	@twitter_account = settings[:user_id_for_twitter] ? User.find(settings[:user_id_for_twitter]).handle : nil
  	@newsletter_link = settings[:newsletter_link]
  	@admins = User.where(admin: true)
  end
end
