require 'spec_helper'
describe User do
	it { should have_many(:events) }

	context '.from_omniauth' do
		subject { User.from_omniauth(auth) }

		context 'when passed a previously saved auth hash' do
			let (:user) { FactoryGirl.create :user }
			let (:auth) { { provider: user.provider, uid: user.uid, 'credentials' => { token: user.twitter_token, secret: user.twitter_secret } } }

			it { should == user }
		end

		context 'when passed a new auth hash' do
			let (:auth) { { provider: 'twitter', uid: '987654321', 'credentials' => { token: 'abcdefg', secret: '111222333' },  'info' => { nickname: 'janedoe' } } }

			it 'persists a user' do
				expect { subject }.to change(User, :count).by 1
			end

			its (:provider) { should == auth['provider'] }
			its (:uid) { should == auth['uid'] }
			its (:twitter_token) { should == auth['credentials']['token'] }
			its (:twitter_secret) { should == auth['credentials']['secret'] }
			its (:handle) { should == auth['info']['nickname'] }
		end
	end

	context '#process_email_update' do
		let(:user) { FactoryGirl.create :user }
		let(:new_email) { "janedoe@doe.com" }

		subject { user.process_email_update(new_email) }

		it 'updates the email address' do
			expect { subject }.to change(user, :email).from(user.email).to(new_email)
		end

		context 'with exsisting email address' do
			context 'was subscribed to newsletter' do
				before { user.should_receive(:subscribed_to_newsletter?).and_return(true) }

				it 'unsubscribes the old email address' do
					Gibbon.should_receive(:listUnsubscribe).with({ id: ENV['MC_LIST_ID'], email_address: user.email, double_optin: false })
					subject
				end

				it 'subscribes the new email address' do
					Gibbon.should_receive(:listSubscribe).with({ id: ENV['MC_LIST_ID'], email_address: new_email, double_optin: false })
					subject
				end
			end

			context 'was not subscribed to newsletter' do
				before { user.should_receive(:subscribed_to_newsletter?).and_return(false) }

				it 'does not subscribe the new email address' do
					Gibbon.should_not_receive(:listSubscribe)
					subject
				end
			end
		end

		context 'without exsisting email address' do
			let(:user) { FactoryGirl.create :user, email: nil }

			it 'does not unsubscribe anything' do
				Gibbon.should_not_receive(:listUnsubscribe)
				subject
			end

			it 'subscribes the new email address' do
				Gibbon.should_receive(:listSubscribe).with({ id: ENV['MC_LIST_ID'], email_address: new_email, double_optin: false })
				subject
			end
		end

		context 'with an invalid new email address' do
			let(:new_email) { "some-bad_EMAIL" }

			it 'should not update the email address' do
				expect { subject }.to change(user, :valid?).from(true).to(false)
			end

			it 'should not subscribe or unsubscribe the email address' do
				Gibbon.should_not_receive(:listUnsubscribe)
				Gibbon.should_not_receive(:listSubscribe)
				subject
			end
		end
	end
end