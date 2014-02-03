# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

open(Rails.root.join('doc', 'seed_countries.txt')) do |countries|
  countries.read.each_line do |country|
    code, name = country.chomp.split("|")
    Country.create!(code: code, name: name)
  end
end

FactoryGirl.create(:user, email: "email@example.com", email_confirmation: "email@example.com")