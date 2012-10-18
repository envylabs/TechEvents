require 'spec_helper'

describe Event do
	it { should belong_to(:user) }
	it { should belong_to(:group)}

	let(:event) { FactoryGirl.create :event }

	context '.upcoming' do
		let!(:event_in_future) { FactoryGirl.create(:event, start_at: (Time.zone.now + 1.hour), end_at: (Time.zone.now + 2.hour)) }
		let!(:event_in_past) { FactoryGirl.create(:event, start_at: (Time.zone.now - 2.hour), end_at: (Time.zone.now - 1.hour)) }

		subject { Event.upcoming }

		it 'should return all events in the future' do
			subject.should have(1).items
		end
	end

	context '.data_for_list' do
		let!(:current_month) { Time.zone.now.strftime("%B") }
		let!(:events) { Event.upcoming }

		subject { Event.data_for_list }

		it 'should return a hash with two items' do
			subject.should have(2).itens
		end
	end

	context '#address' do
		context 'with event whos address was already determined' do
			it 'returns a string of the address' do
				event.address.should == [event.street, event.city, event.state, event.country].compact.join(', ')
			end
		end

		context 'with an event whos address is to be determined' do
			let (:event) { FactoryGirl.create(:event, address_tbd: true) }

			it 'returns nil' do
				event.address.should == nil
			end
		end
	end

	context "#schedule_social_media" do
		before { event.schedule_social_media }

		it 'schedules the first post' do
			Delayed::Job.where(run_at: event.start_at - 4.hours).should_not be_empty
		end

		it 'schedules the last post' do
			Delayed::Job.where(run_at: event.start_at - 15.minutes).should_not be_empty
		end

		it 'runs the jobs' do
			client_stub = mock_model('TwitterClient')
			client_stub.should_receive(:update).exactly(2).times
			Twitter::Client.should_receive(:new).exactly(2).times.and_return(client_stub)
			Delayed::Worker.new.work_off
		end
	end

	context '#init_datetimes' do
		let(:new_start_at) { Time.zone.now + 2.hour }
		let(:new_end_at) { Time.zone.now + 3.hour }
		let!(:event) { FactoryGirl.create(:event, start_at: new_start_at, end_at: new_end_at) }

		it 'should return the correct start timestamp' do
			event.start_at.should == new_start_at
		end

		it 'should return the correct end timestamp' do
			event.end_at.should == new_end_at
		end
	end
end