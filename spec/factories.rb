def numbers_to_letters(n)
  n.to_s.split(//).map{ |d| ('a'..'z').to_a[d.to_i] }.join
end

FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
    first_name "John"
    last_name "Doe"

    factory :admin do
      admin true
    end
  end

  factory :job do
    sequence(:name) { |n| "Random job " + numbers_to_letters(n) }
  end
end

