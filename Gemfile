source 'https://rubygems.org'

gem 'rails', '3.2.11'

# Settings
gem 'rails-settings-cached', '~> 0.2.4'

# DelayedJob
gem 'daemons', '~> 1.1.9'
gem 'delayed_job_active_record', '~> 0.3.3'

# Mailchimp
gem 'gibbon', '~> 0.3.5'

# Authentication/Authorization
gem 'omniauth-twitter', '~> 0.0.14'
gem 'cancan', '~> 1.6.9'

# Image Uploads
gem 'fog', '~> 1.3.1'
gem 'mini_magick', '~> 3.4'
gem 'carrierwave', '~> 0.6.2'

# Geocoding
gem 'geocoder', '~> 1.1.6'

# Calendar
gem 'ri_cal', '~> 0.8.8'

# Social media
gem 'twitter', '~> 4.5.0'

# Interface
gem 'haml-rails', '~> 0.3.5'
gem 'anjlab-bootstrap-rails', '~> 2.0.4.3', :require => 'bootstrap-rails'
gem 'jquery-rails'

group :development do
	gem 'sqlite3'
	gem 'localtunnel'
	gem 'delayed_job_web', '~> 1.1.2'
end

group :production do
	gem 'pg'
end

group :assets do
	gem 'sass-rails',   '~> 3.2.6'
	gem 'coffee-rails', '~> 3.2.2'
	gem 'uglifier', '>= 1.3.0'
end

group :test, :development do
	gem 'rspec-rails', '~> 2.11.1'
	gem 'shoulda-matchers', '~> 1.2.0'
	gem 'factory_girl_rails', '~> 3.5.0'
	gem 'capybara', '~> 1.1.2'
	gem 'pry-rails', '~> 0.2.2'
end