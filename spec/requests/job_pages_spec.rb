require 'spec_helper'

describe "Job" do

  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "for a record not found" do
    before { FactoryGirl.create(:job) }

    {"edit" => "edit_job_path(Job.last.id + 1)",
     "activate" => "activate_job_path(Job.last.id + 1)",
     "desactivate" => "desactivate_job_path(Job.last.id + 1)"}.each do |path|
      context "from the #{path.first} action" do
        before { visit eval(path.last) }

        it { should have_title "Error" }
        it { should have_content "The page you were looking for doesn't exist." }
      end
    end
  end

  describe "a user visits the index page" do
    before { visit jobs_path }

    describe "when he click to the add button" do
      before { click_button "Add a job" }
      it { should have_title "Add a job" }
    end

    describe "per-page setting" do
      within(:css, ".per_page") do
        it { should have_content "Per page :" }
        JOBS_PER_PAGE.each do |number|
          it { should have_link number.to_s, per_page_jobs(number.to_s) }
        end
      end
    end

    describe "flashs" do
      context "when a job has just been removed", :js => true do
        let!(:job) { FactoryGirl.create(:job) }
        before do
          visit jobs_path
          click_link "delete_#{job.id}"
        end
        it "aaa" do
          page.driver.browser.switch_to.alert.accept
          expect(page).to have_selector ".alert-success", text: "Job deleted successfully"
        end
      end
    end

    before do
      FactoryGirl.create_list(:job, :sample, 8)
      visit jobs_path
    end

    describe "list" do
      describe "columns" do
        within(:css, "table th.sort") do
          it { should have_link "Name", sort_jobs_path("name") }
          it { should have_link "Active", sort_jobs_path("active") }
        end
        it { should have_selector "table th", text: "Actions" }
      end

      describe "rows" do
        Job.all.each do |job|
          within(:css, "table #row_#{job.id}") do
            it { should have_selector("td", text: job.name) }
            if job.active?
              it { should have_selector("td", text: "Yes") ) }
              it { should have_link "Desactivate", desactivate_job_path(job) }
            else
              it { should have_selector("td", text: "No") ) }
              it { should have_link "Activate", activate_job_path(job) }
            end
            it { should have_link "Edit", edit_job_path(job) }
            selector = "a[data-method='delete']" \
              + "[data-confirm='Are you sure ?']" \
              + "[href='#{url_for(job_path(job))}']"
            it { should have_selector selector, text: "Delete" }
          end
        end
      end
    end

  end

  describe "a user visits the page to create a new job" do
    before { visit new_job_path }
    include_examples "job form requests", "Add a job", "Job saved successfully."
  end

  describe "a user visits the page to update a new job" do
    let(:job) { FactoryGirl.create(:job) }
    before { visit edit_job_path(job) }
    include_examples "job form requests", "Edit a job", "Job updated successfully."
  end
end