require 'spec_helper'

describe SessionsController do
	context '#create' do
		let (:user) { FactoryGirl.create(:user, email: nil) }

		subject do 
			User.should_receive(:from_omniauth).and_return(user)
			get :create, provider: "twitter"
		end

		it "sets the user's id in the session" do
			subject
			session[:user_id].should == user.id
		end

		context 'First time user' do
			it 'redirects to UsersController#initial_setup' do	
				subject			
				response.should redirect_to(edit_user_url)
			end
		end

		context 'Returning user' do
			let (:user) { FactoryGirl.create(:user) }

			it 'redirects to root path with a notice' do
				subject
				response.should redirect_to(root_url)
				flash[:notice].should == 'Signed in!'
			end
		end
	end

	context '#destroy' do
		let (:user) { FactoryGirl.create(:user) }
		subject do
			session[:user_id] = user.id
			get :destroy
		end

		it "unsets the user's id from the session" do
			subject
			session[:user_id].should == nil
		end

		it 'redirects to root path with a notice' do
			subject
			response.should redirect_to(root_url)
			flash[:notice].should == 'Signed out!'
		end
	end
end