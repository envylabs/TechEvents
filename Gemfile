source 'https://rubygems.org'

gem 'rails', '3.2.6'

# Mailchimp
gem 'gibbon', '~> 0.3.5'

# Authentication/Authorization
gem 'omniauth-twitter', '~> 0.0.12'
gem 'cancan', '~> 1.6.8'

# Geocoding
gem 'geocoder', '~> 1.1.2'

# Interface
gem 'haml-rails', '~> 0.3.4'
gem 'anjlab-bootstrap-rails', '~> 2.0.4.3', :require => 'bootstrap-rails'

group :development do
	gem 'sqlite3'
	gem 'heroku'
	gem 'localtunnel'
end

group :production do
	gem 'pg'
end

group :assets do
	gem 'sass-rails',   '~> 3.2.3'
	gem 'coffee-rails', '~> 3.2.1'
	gem 'uglifier', '>= 1.0.3'
end

group :test, :development do
	gem 'rspec-rails', '~> 2.11.0'
	gem 'shoulda-matchers', '~> 1.2.0'
	gem 'factory_girl_rails', '~> 3.5.0'
	gem 'capybara', '~> 1.1.2'
end

gem 'jquery-rails'