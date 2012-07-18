require 'spec_helper'
describe User do
	it { should have_many(:events) }

	context '.from_omniauth' do
		subject { User.from_omniauth(auth) }

		context 'when passed a previously saved auth hash' do
			let (:user) { FactoryGirl.create :user }
			let (:auth) { { provider: user.provider, uid: user.uid } }

			it { should == user }
		end

		context 'when passed a new auth hash' do
			let (:auth) { { provider: 'twitter', uid: '987654321', 'credentials' => { token: 'abcdefg' },  'info' => { nickname: 'janedoe' } } }

			it 'persists a user' do
				expect { subject }.to change(User, :count).by 1
			end

			its (:provider) { should == auth['provider'] }
			its (:uid) { should == auth['uid'] }
			its (:token) { should == auth['credentials']['provider'] }
			its (:handle) { should == auth['info']['nickname'] }
		end
	end
end