FactoryGirl.define do
	factory :event do
		name 'My Event'
		description 'A really long description'
		link 'http://meetup.com/'
		start_time '2012-07-20T19:30:00Z'
		end_time '2012-07-20T20:30:00Z'
		latitude 28.5410417
		longitude -81.3787435
		original_address '121 South Orange Avenue #1050, Orlando, FL'
		street '121 S Orange Ave'
		city 'Orlando'
		state 'Florida'
		country 'United States'
		notes 'Join us on the 20th floor'
		newsletter false
		address_tbd false
		user
		group
	end
end