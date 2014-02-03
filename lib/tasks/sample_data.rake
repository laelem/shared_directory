namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    FactoryGirl.create_list(:job, 100, :sample)
    FactoryGirl.create_list(:user, 100, :sample)
    FactoryGirl.create_list(:contact, 100, :sample)
  end
end
