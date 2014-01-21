include SessionsHelper

Given(/^the following users exist:$/) do |table|
  table.raw.each_with_index do |raw, i|
    instance_variable_set "@user" + i.to_s, User.create({ :email => raw[0],
      :password => raw[1], :password_confirmation => raw[1] })
  end
end

Given(/^a user is not logged in$/) do
  sign_out
end

Given(/^a user is logged in$/) do
  visit root_url
  fill_in "email", with: @user1.email
  fill_in "password", with: @user1.password
  click_button "Sign in"
end



When(/^he visits the home page$/) do
  visit root_url
end

When(/^he enters "(.*?)" in the email field$/) do |email|
  fill_in "email", with: email
end

When(/^he enters "(.*?)" in the password field$/) do |password|
  fill_in "password", with: password
end

When(/^he press the sign in button$/) do
  click_button "Sign in"
end




Then(/^he should see the sign in form$/) do
  page.should have_selector("#sign_in_form")
end

Then(/^he should not see the sign in form$/) do
  page.should_not have_selector("#sign_in_form")
end

Then(/^he should see the error message: "(.*?)"$/) do |message|
  page.should have_selector(".error", text: message)
end

Then(/^he should not be logged in$/) do
  page.should have_selector("#sign_in_form")
end

Then(/^he should be logged in$/) do
  page.should_not have_selector("#sign_in_form")
end