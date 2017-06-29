2.times do
  User.create!(email: Faker::Internet.free_email, password: 'password')
end
