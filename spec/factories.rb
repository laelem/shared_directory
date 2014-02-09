require 'open-uri'

class FakeUploadedfile
  attr_accessor :original_filename, :tempfile
  def initialize(tempfile, original_filename)
    @tempfile = tempfile
    @original_filename = original_filename
  end
end

def create_photo
  file = Tempfile.open('fake')
  File.open(file, "wb") do |f|
    f.write(open("http://lorempixel.com/100/100/people").read)
  end
  return FakeUploadedfile.new(file, 'fake.jpg')
end

def numbers_to_letters(n)
  n.to_s.split(//).map{ |d| ('a'..'z').to_a[d.to_i] }.join
end

def random_phone_number
  '0' + rand(1..5).to_s + (['']*8).map{ rand(9).to_s }.join
end

def random_mobile_number
  '0' + rand(6..7).to_s + (['']*8).map{ rand(9).to_s }.join
end

FactoryGirl.define do

  factory :country do
    code "XY"
    name "New Country"
  end

  factory :job do
    name { |n| Faker::Name.title }

    trait :sample do
      sequence(:active) { |n| n % 3 }
    end
  end

  factory :user do
    email "user@example.com"
    email_confirmation "user@example.com"
    password "foobar"
    password_confirmation "foobar"
    first_name "John"
    last_name "Doe"

    trait :sample do
      email                 { @fake_email = Faker::Internet.email }
      email_confirmation    { @fake_email }
      first_name            { Faker::Name.first_name }
      last_name             { Faker::Name.last_name }
      sequence(:active)     { rand(3) != 0 }
      sequence(:admin)      { rand(3) != 0 }
    end
  end

  factory :contact do
    civility "Mr"
    first_name "John"
    last_name "Doe"
    date_of_birth "19/06/1988"
    email "user@example.com"
    jobs { [FactoryGirl.create(:job)] }

    trait :sample do
      active        { rand(3) != 0 }
      civility      { CIV.keys[rand(3)] }
      first_name    { Faker::Name.first_name }
      last_name     { Faker::Name.last_name }
      date_of_birth { rand(120.years.ago.to_date..Date.today).strftime("%d/%m/%Y") }
      jobs          { Job.where(active: true).order('RANDOM()').limit(rand(1..3)) }

      sequence(:address)  { |n| if n%3 == 0 then '' else Faker::Address.street_address end }
      sequence(:zip_code) { |n| if n%3 == 0 then '' else rand(10000..99999).to_s end }
      sequence(:city)     { |n| if n%3 == 0 then '' else Faker::Address.city end }
      sequence(:country)  { |n| if n%3 == 0 then nil else Country.order('RANDOM()').first end }

      sequence(:phone_number)  { |n| if (n+1)%3 == 0 then '' else random_phone_number end }
      sequence(:mobile_number) { |n| if (n+1)%3 == 0 then '' else random_mobile_number end }

      email { Faker::Internet.email }

      sequence(:upload_photo) { |n| if (n+2)%3 == 0 then nil else create_photo end }
      sequence(:website)      { |n| if (n+2)%3 == 0 then '' else Faker::Internet.url end }
      sequence(:comment)      { |n| if (n+2)%3 == 0 then '' else Faker::Lorem.paragraphs.join("\r\n")[0..499] end }
    end
  end
end

