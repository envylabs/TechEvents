require 'spec_helper'

describe Event do
	it { should belong_to(:user) }
	it { should belong_to(:group)}

	context '.upcoming' do
		let!(:event_in_future) { FactoryGirl.create(:event, start_time: (Time.now + 1.hour), end_time: (Time.now + 2.hour)) }
		let!(:event_in_past) { FactoryGirl.create(:event, start_time: (Time.now - 2.hour), end_time: (Time.now - 1.hour)) }

		subject { Event.upcoming }

		it 'should return all events in the future' do
			subject.should have(1).items
		end
	end

	context '#address' do
		let(:event) { FactoryGirl.create :event }

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
end