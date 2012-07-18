require 'spec_helper'

describe EventsController do
	context '#index' do
		let (:events) { FactoryGirl.create(:event) }
		subject { get :index }

		it 'renders a page' do
			subject
		end

		it 'queries all events' do
			pending
		end
	end

	context '#new' do
		subject { get :new }

		it 'renders a page' do
			subject
		end

		it 'initializes a new Event object' do
			pending
		end
	end

	context '#edit' do
		it 'renders a page' do
			pending
		end

		it 'finds the requested Event object' do
			pending
		end
	end

	context '#create' do
		subject { post :create }

		it 'saves an event' do
			pending
		end

		it 'redirects to events_path with a notice' do
			pending
		end
	end

	context '#update' do
		subject { put :update }

		it 'updates an event' do
			pending
		end

		it 'redirects to events_path with a notice' do
			pending
		end
	end
end