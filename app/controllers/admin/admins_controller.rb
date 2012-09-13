class Admin::AdminsController < Admin::BaseController
  # POST /admin/admins
  def create
  	user = User.where(handle: params[:handle]).first

  	if user.update_attributes(admin: true)
  		redirect_to admin_root_url, notice: "@#{user.handle} was appointed admin rights."
  	end
  end

  # DELETE /admin/admins/1
  def destroy
  	user = User.find(params[:id])

  	if user != current_user && user.update_attributes(admin: false)
		redirect_to admin_root_url, notice: "@#{user.handle} was appointed admin rights."
	else
		redirect_to admin_root_url, notice: "You can not remove your own admin rights."
  	end
  end
end
