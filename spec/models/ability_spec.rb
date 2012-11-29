require 'spec_helper'
require 'cancan/matchers'
describe Ability do
	subject { ability }
	let(:ability) { Ability.new(user) }

	context 'User is an admin' do
		let(:user) { FactoryGirl.create :user, admin: true }

		it { should be_able_to :manage, User.new }
		it { should be_able_to :manage, Event.new }
	end

	context 'User is not an admin' do
		let (:user) { FactoryGirl.create :user }

		it { should be_able_to :read, User.new }
		it { should_not be_able_to :create, User }
		it { should be_able_to :update, user }
		it { should_not be_able_to :update, FactoryGirl.create(:user) }
		it { should_not be_able_to :delete, User.new }

		it { should be_able_to :read, Event.new }
		it { should be_able_to :create, Event }
		it { should be_able_to :update, FactoryGirl.create(:event, user: user) }
		it { should_not be_able_to :update, FactoryGirl.create(:event) }
		it { should_not be_able_to :delete, Event.new}
	end

	context 'User is not logged in' do
		let (:user) { nil }

		it { should be_able_to :read, User.new }
		it { should be_able_to :create, User }
		it { should_not be_able_to :update, User.new }
		it { should_not be_able_to :delete, User.new }

		it { should be_able_to :read, Event.new }
		it { should_not be_able_to :create, Event }
		it { should_not be_able_to :update, Event.new }
		it { should_not be_able_to :delete, Event.new }
	end	
end