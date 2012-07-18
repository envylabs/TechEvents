require 'yaml'
require 'erb'

# Load API keys if not running in production on Heroku
if !Rails.env.production?
	ENV = YAML.load_file("#{Rails.root}/config/keys.yml")[Rails.env]
end