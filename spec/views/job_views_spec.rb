require 'spec_helper'

describe "Job views" do

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

  describe "index" do
    it { should have_title "List of jobs" }
    it { should have_link "Add a job", new_job_path }

    describe "per-page setting" do
      within(:css, ".per_page") do
        it { should have_content "Per page :" }
        JOBS_PER_PAGE.each do |number|
          it { should have_link number.to_s, per_page_jobs(number.to_s) }
        end
      end
    end

    context "when no job is present" do
      before { visit jobs_path }

      it { should have_content "No job is present." }
      it { should_not have_content "0 job" }
      it { should_not have_selector "div.pagination" }
      it { should_not have_selector "table" }
      it { should_not have_selector ".per_page" }
    end

    context "when one job is present" do
      before do
        FactoryGirl.create(:job)
        visit jobs_path
      end

      it { should have_content "1 job" }
      it { should_not have_content "1 jobs" }
      it { should_not have_selector "div.pagination" }
      it { should have_selector "table" }
      it { should have_selector ".per_page" }
    end

    context "when many jobs are present" do
      describe "list" do
        before do
          FactoryGirl.create_list(:job, :sample, 2)
          visit jobs_path
        end

        describe "columns" do
          within(:css, "table th.sort") do
            it { should have_link "Name" }
            it { should have_link "Active" }
          end
          it { should have_selector "table th", text: "Actions" }
        end

        describe "rows" do
          Job.all.each do |job|
            within(:css, "table #row_#{job.id}") do
              it { should have_selector("td", text: job.name) }
              if job.active?
                it { should have_selector("td", text: "Yes") ) }
                it { should have_link "Desactivate" }
              else
                it { should have_selector("td", text: "No") ) }
                it { should have_link "Activate" }
              end
              it { should have_link "Edit" }
              it { should have_link "Delete" }
            end
          end
        end
      end

      describe "pagination" do
        context 'with 2 records' do
          before do
            FactoryGirl.create_list(:job, :sample, 2)
            visit jobs_path
          end
          it { should_not have_selector ".pagination" }
        end

        context 'with 3 records' do
          before do
            FactoryGirl.create_list(:job, :sample, 3)
            visit jobs_path
          end
          within(:css, ".pagination") do
            it { should have_link "Previous" }
            it { should have_link "1" }
            it { should have_link "2" }
            it { should_not have_link "3" }
            it { should have_link "Next" }
          end
        end

        context 'with 17 records' do
          before do
            FactoryGirl.create_list(:job, :sample, 17)
            visit jobs_path
          end
          within(:css, ".pagination") do
            it { should have_link "Previous" }
            it { should have_link "1" }
            it { should have_link "2" }
            it { should have_link "3" }
            it { should have_link "4" }
            it { should have_link "5" }
            it { should have_link "..." }
            it { should have_link "8" }
            it { should have_link "9" }
            it { should_not have_link "6" }
            it { should_not have_link "7" }
            it { should have_link "Next" }
          end
        end
      end
    end
  end

  describe "new record form" do
    before { visit new_job_path }

    it { should have_title "Add a job" }
    it { should have_selector "h1", text: "Add a job" }
    include_examples "job form template"
  end

  describe "edit record form" do
    let!(:job) { FactoryGirl.create(:job) }
    before { visit edit_job_path(job) }

    it { should have_title "Edit a job" }
    it { should have_selector "h1", text: "Edit a job" }
    include_examples "job form template"
  end
end