FactoryGirl.define do
	factory :user do
		provider 'twitter'
		uid '123456789'
		token 'aaabbbccc111222333'
		handle 'johndoe'
		email 'johndoe@gmail.com'
		admin false
	end
end