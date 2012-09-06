require 'yaml'
require 'erb'

# Load API keys from config/keys.yml if not running in production
if !Rails.env.production?
	ENV = YAML.load_file("#{Rails.root}/config/keys.yml")[Rails.env]
end