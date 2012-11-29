class Admin::AdminsController < Admin::BaseController
  # POST /admin/admins
  def create
    if user = User.where(handle: params[:handle]).first
      user.make_admin ? redirect_to(admin_root_url, notice: "@#{user.handle} was appointed admin rights.") : redirect_to(admin_root_url, notice: "There was an unknown error.")
    else
      redirect_to(admin_root_url, notice: "@#{params[:handle]} is not a user.")
    end
  end

  # DELETE /admin/admins/1
  def destroy
  	user = User.find(params[:id])
    user.remove_admin(current_user) ? redirect_to(admin_root_url, notice: "Admin rights removed from @#{user.handle}.") : redirect_to(admin_root_url, notice: "You can not remove your own admin rights.")
  end
end
