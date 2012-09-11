class Admin::SocialController < Admin::BaseController
  # PUT /admin/social/set_account
  def update
    if Settings.user_id_for_twitter = current_user.id
      redirect_to admin_root_url, :notice => '@' + current_user.handle + ' will now be used for updating Tech Events on Twitter!'
    end
  end
end
