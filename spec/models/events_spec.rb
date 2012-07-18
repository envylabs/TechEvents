require 'spec_helper.rb'

describe Event do
	it { should belong_to(:user) }
end