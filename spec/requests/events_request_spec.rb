require 'spec_helper'

describe 'Events' do
	describe '#index' do
		let!(:previous_event) { FactoryGirl.create :event, name: 'Previous Event', start_at: Time.new - 2.hour, end_at: Time.new - 1.hour }
		let!(:upcoming_event) { FactoryGirl.create :event, name: 'Upcoming Event', start_at: Time.new + 1.hour, end_at: Time.new + 2.hour }
		let!(:next_upcoming_event) { FactoryGirl.create :event, name: 'Next Upcoming Event', start_at: Time.new + 1.month, end_at: Time.new + 1.month + 1.hour}

		before do
			visit events_path
		end

		it 'displays an upcoming event' do	
			find('.upcoming-events').should have_content(upcoming_event.name)
		end

		it 'does not display a previous event' do
			find('.upcoming-events').should_not have_content(previous_event.name)
		end

		it 'should display soonest events first' do
			events = [upcoming_event, next_upcoming_event]

			all('.event-entry').each_with_index do |event, index|
				event.find('h3').should have_content(events[index].name)
			end
		end
	end

	describe '#new' do
		let(:user) { FactoryGirl.create :user }

		subject { session[:post_auth_path] = nil }

		before do
			OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(:provider => user.provider, :uid => user.uid, 'credentials' => { :token => user.twitter_token, :secret => user.twitter_secret })

			visit events_path

			within('.post-event') do
				find_link('Post an event').click
			end
		end

		context 'User is not logged in' do
			it 'redirects the User to "/auth/twitter", logs them in, then redirects them back to new_event_path' do
				current_path.should == new_event_path
			end
		end

		context 'User is logged in' do
			subject { session[:user_id] = user.id }

			it 'allows the user to view the form' do
				current_path.should == new_event_path
			end

			it 'allows the user to create a valid event'
		end
	end
end