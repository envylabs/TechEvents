require 'spec_helper'

describe 'Events' do
	describe '#index' do
		let!(:previous_event) { FactoryGirl.create :event, name: 'Previous Event', start_time: Time.new - 2.hour, end_time: Time.new - 1.hour }
		let!(:upcoming_event) { FactoryGirl.create :event, name: 'Upcoming Event', start_time: Time.new + 1.hour, end_time: Time.new + 2.hour }
		let!(:next_upcoming_event) { FactoryGirl.create :event, name: 'Next Upcoming Event', start_time: Time.new + 1.day + 1.hour, end_time: Time.new + 1.day + 2.hour}

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
		before do
			visit events_path
			within('.post-event') do
				find_link('Post an event').click
			end
		end

		context 'User is not logged in' do
			it 'does not allow the user to post an event' do
				current_path.should == root_path
			end
		end

		context 'User is logged in' do
			let(:user) { FactoryGirl.create :user }

			before do
				OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new(:provider => user.provider, :uid => user.uid)
				
				within('.navbar') do
					find_link('Sign in').click
				end

				within('.post-event') do
					find_link('Post an event').click
				end
			end

			it 'allows the user to view the form' do
				current_path.should == new_event_path
			end

			# Waiting for propper date selector to be finished.
			# it 'allows the user to create a valid event' do
			# 	fill_in('Name', with: 'My Event')
			# 	fill_in('Description', with: 'This event is .. an event!')
			# 	fill_in('Link', with: 'http://envylabs.com/')
			# 	# start & end
			# 	fill_in('Address', with: '121 S Orange Ave, Orlando, FL')
			# 	fill_in('Notes', with: 'Some notes for the event')
			# end
		end
	end
end