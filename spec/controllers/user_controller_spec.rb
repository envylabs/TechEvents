require 'spec_helper'

describe UserController do
	let (:user) { FactoryGirl.create(:user, email: nil) }
	before { session[:user_id] = user.id }

	context '#edit' do
		subject do
			get :edit
		end

		it 'redirects to login if a current_user is not present' do
			session[:user_id] = nil
			subject
			response.should redirect_to('/auth/twitter')
		end
		
		it 'renders a page' do
			subject
		end

		it 'finds the current user' do
			subject
			assigns(:user).should == user
		end
	end

	context '#update' do
		subject do
			put :update, user: { email: 'johndoe@gmail.com' }
		end

		it 'updates the email address' do
			subject
			assigns(:current_user).email.should == 'johndoe@gmail.com'
		end

		it 'redirects to root path with a notice' do
			subject
			response.should redirect_to(root_url)
			flash[:notice].should == 'Email address updated!'
		end
	end
end