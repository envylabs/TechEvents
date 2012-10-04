require 'spec_helper'

describe Event do
	it { should belong_to(:user) }
	it { should belong_to(:group)}

	context '#address' do
		let(:event) { FactoryGirl.create :event }

		context 'with event whos address was already determined' do
			it 'returns a string of the address' do
				event.address.should == [event.street, event.city, event.state, event.country].compact.join(', ')
			end
		end

		context 'with an event whos address is to be determined' do
			before { event.address_tbd = true }

			it 'returns nil' do
				event.address.should == nil
			end
		end
	end
end