require 'spec_helper'

describe Event do
	it { should belong_to(:user) }
	it { should belong_to(:group)}
end