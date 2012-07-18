FactoryGirl.define do
	factory :event do
		name 'My Event'
		description 'A really long description'
		link 'http://meetup.com/'
		start_time '2012-07-20T19:30:00Z'
		end_time '2012-07-20T20:30:00Z'
		latitude ''
		longitude ''
		human_address ''
		newsletter false
		user
	end
end