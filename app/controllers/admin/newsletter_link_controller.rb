class Admin::NewsletterLinkController < Admin::BaseController
  # POST /admin/newsletter_link
  def update
    (Settings.newsletter_link = "#{params[:link]}") ? redirect_to(admin_root_url, notice: "Current newsletter link successfully updated.") : redirect_to(admin_root_url, notice: "There was an unknown error.")
  end
end
