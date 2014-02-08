namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    puts "-- Create job data : 100"
    puts "..."
    FactoryGirl.create_list(:job, 100, :sample)

    puts "-- Create user data : 100"
    puts "..."
    FactoryGirl.create_list(:user, 100, :sample)

    puts "-- Create contact data : 100"
    puts "..."
    FactoryGirl.create_list(:contact, 100, :sample)
  end
end
