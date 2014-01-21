Given(/^no job is saved$/) do
  Job.destroy_all
end

Given(/^the following jobs exist:$/) do |table|
  table.raw.each_with_index do |raw, i|
    instance_variable_set "@job" + i.to_s, Job.create({ :name => raw[0],
      :active => raw[1] })
  end
end


When(/^a user press the "(.*?)" menu link$/) do |link|
  within(:css, "#nav") do
    click_link link
  end
end


Then(/^he should see a message saying no "(.*?)" is present$/) do |item|
  page.should have_content("No #{item} is present")
end

Then(/^he should see the job list page$/) do
  page.should have_selector("h2", text: "List of jobs")
end

Then(/^he should see the existing jobs$/) do
  Job.all.each do |job|
    expect(page).to have_selector("#job_#{job.id} td", text: job.name)
  end
end

Then(/^the non active jobs should be grayed$/) do
  Job.all.each do |job|
    unless job.active
      expect(page).to have_selector("#job_#{job.id}.inactive")
    end
  end
end
