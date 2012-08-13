require 'spec_helper'

describe 'Subscription' do
	context 'visitor wants to subscribe to newsletter from events#index' do
		let(:email) { "johndoe@gmail.com" }

		before do
			visit events_path
		end

		it 'should display the form' do
			have_field('#subscription_email')
		end

		context 'visitor submits the newsletter subscription form' do
			context 'visitor is not already subscribed' do
				it 'displays success message'
			end

			context 'visitor is already subscribed' do
				it 'displays already subscribed message'
			end
		end
	end
end