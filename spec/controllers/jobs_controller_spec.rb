require 'spec_helper'

describe JobsController do

  test_paths = ["get 'index'",
                "get 'new'",
                "post 'create', job: #{FactoryGirl.attributes_for(:job)}",
                "get 'edit', id: '#id'",
                "patch 'update', job: #{FactoryGirl.attributes_for(:job)}, id: '#id'",
                "delete 'destroy', id: '#id'",
                "get 'toggle_status', id: '#id'",
                "get 'sort', field: '#{JOBS_DEFAULT_SORT[:field]}'",
                "get 'per_page', number: '#{JOBS_DEFAULT_PER_PAGE}'"]

  describe "global callbacks" do
    let(:job) { FactoryGirl.create(:job) }

    describe "non-signed-in users redirections to the signin page" do
      test_paths.each do |test_path|
        it "should be applied for : #{test_path}" do
          eval(test_path.gsub("#id", job.id.to_s))
          expect(response).to redirect_to(signin_path)
        end
      end
    end

    describe "jobs session initialisation" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user, no_capybara: true }

      test_paths.each do |test_path|
        it "should be applied for : #{test_path}" do
          eval(test_path.gsub("#id", job.id.to_s))
          expect(session[:jobs]).to_not be_nil
          expect(session[:jobs][:per_page]).to_not be_nil
          expect(session[:jobs][:sort]).to_not be_nil
          expect(session[:jobs][:sort][:field]).to_not be_nil
          expect(session[:jobs][:sort][:type]).to_not be_nil
        end
      end
    end
  end

  describe "actions" do

    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user, no_capybara: true }

    describe "common behavior" do
      describe "search a record" do
        test_paths.each do |test_path|
          if /#id/.match(test_path)
            context "when the id is not valid" do
              before { FactoryGirl.create(:job) }

              it "should raise an error" do
                test_path = test_path.gsub("#id", (Job.last.id + 1).to_s)
                expect{ eval(test_path) }.to raise_error(ActiveRecord::RecordNotFound)
              end
            end
          end
        end
      end
    end

    describe "GET #index" do
      subject(:jobs) { assigns('jobs') }

      context "with no data" do
        before { get :index }
        it { should eq [] }
        include_examples "render view", "index"
      end

      context "with datas" do
        before do
          @job1 = Job.create(active: true, name: "Developer")
          @job2 = Job.create(active: false, name: "Magician")
          @job3 = Job.create(active: true, name: "Confectionner")
          @job4 = Job.create(active: false, name: "Architect")
        end

        context "with no particular settings" do
          before { get :index }
          it { should eq [@job4, @job3] }
          include_examples "render view", "index"
        end

        context "with a sort" do
          before { session[:jobs] = { per_page: JOBS_DEFAULT_PER_PAGE } }

          context "by active field" do
            before { session[:jobs][:sort] = {field: "active"} }

            context "ascending" do
              before do
                session[:jobs][:sort][:type] = "asc"
                get :index
              end
              it { should eq [@job2, @job4] }
              include_examples "render view", "index"
            end

            context "descending" do
              before do
                session[:jobs][:sort][:type] = "desc"
                get :index
              end
              it { should eq [@job1, @job3] }
              include_examples "render view", "index"
            end
          end

          context "by name field" do
            before { session[:jobs][:sort] = {field: "name"} }

            context "ascending" do
              before do
                session[:jobs][:sort][:type] = "asc"
                get :index
              end
              it { should eq [@job4, @job3] }
              include_examples "render view", "index"
            end

            context "descending" do
              before do
                session[:jobs][:sort][:type] = "desc"
                get :index
              end
              it { should eq [@job2, @job1] }
              include_examples "render view", "index"
            end
          end
        end

        context "with a page" do
          context "that is valid" do
            before { get :index, page: "2" }
            it { should eq [@job1, @job2] }
            include_examples "render view", "index"
          end

          context "that is not valid" do
            before { get :index, page: "3" }
            it { should eq [@job4, @job3] }
            include_examples "render view", "index"
          end
        end

        context "with a number of elements per page" do
          before { session[:jobs] = { sort: JOBS_DEFAULT_SORT } }

          [3,4,5].each do |number|
            context "equal to #{number}" do
              before do
                session[:jobs][:per_page] = number
                get :index
              end
              let(:expectation) { if number > Job.count then Job.count else number end }

              its(:size) { should eq expectation }
              include_examples "render view", "index"
            end
          end
        end
      end
    end

    describe "GET #new" do
      before { get :new }

      it "should assign a new job to @job" do
        expect(assigns('job')).to be_new_record
      end
      include_examples "render view", "new"
    end

    describe "POST #create" do
      context "with valid attributes" do
        it "should save the new job in the database" do
          expect{
            post :create, job: FactoryGirl.attributes_for(:job)
          }.to change(Job, :count).by(1)
        end

        before { post :create, job: FactoryGirl.attributes_for(:job) }
        it "should define a success flash message" do
          expect(flash[:success]).to_not be_nil
        end
        include_examples "redirect to", "index", "jobs_path"
      end

      context "with an invalid attribute at least" do
        it "should not save the new job in the database" do
          expect{
            post :create, job: FactoryGirl.attributes_for(:job, active: nil)
          }.to_not change(Job, :count)
        end

        before { post :create, job: FactoryGirl.attributes_for(:job, active: nil) }
        include_examples "render view", "new"
      end

      context "without a require attribute" do
        it "should raise an error" do
          expect{
            post :create, wrong_param: FactoryGirl.attributes_for(:job)
          }.to raise_error ActionController::ParameterMissing
        end
      end

      context "with a non-permitted attribute" do
        context "that doesn't exist" do
          it "should save the record" do
            expect{
              post :create, job: FactoryGirl.attributes_for(:job, wrong_param: "foobar")
            }.to change(Job, :count).by(1)
          end

          before { post :create, job: FactoryGirl.attributes_for(:job, wrong_param: "foobar") }

          it "should not save the fake attribute" do
            expect(Job.last.attributes.keys).to_not include "wrong_param"
          end

          include_examples "redirect to", "index", "jobs_path"
        end
      end
    end

    describe "GET #edit" do
      let!(:job) { FactoryGirl.create(:job) }

      context "with a valid id" do
        before { get :edit, id: "#{job.id}" }

        it "should assign the right job to @job" do
          expect(assigns('job')).to eq Job.find_by_id(job.id)
        end
        include_examples "render view", "edit"
      end
    end

    describe "POST #update" do
      let(:job) { Job.create(name: "Developer abcd", active: true) }

      context "with valid attributes" do
        before { post :update, id: job.id, job: {name: "Magician abcd", active: false} }

        it "should locate the requested job" do
          expect(assigns('job')).to eq job
        end

        it "should update the job in the database" do
          expect(job.reload.name).to eq "Magician abcd"
          expect(job.reload.active).to be_false
        end

        it "should define a success flash message" do
          expect(flash[:success]).to_not be_nil
        end

        include_examples "redirect to", "index", "jobs_path"
      end

      context "with an invalid attribute at least" do
        before { post :update, id: job.id, job: {name: "Magician abcd", active: nil} }

        it "should not update the job in the database" do
          expect(job.reload.name).to eq "Developer abcd"
          expect(job.reload.active).to be_true
        end
        include_examples "render view", "edit"
      end

      context "without a require attribute" do
        it "should raise an error" do
          expect{
            post :update, id: job.id, wrong_param: FactoryGirl.attributes_for(:job)
          }.to raise_error ActionController::ParameterMissing
        end
      end

      context "with a non-permitted attribute" do
        before { post :update, id: job.id, job: {name: "Magician abcd", active: false, wrong_param: "foobar"} }

        context "that doesn't exist" do
          it "should update the record except for the fake attribute" do
            expect(job.reload.name).to eq "Magician abcd"
            expect(job.reload.active).to be_false
            expect(defined? job.reload.wrong_param).to be_false
          end
          include_examples "redirect to", "index", "jobs_path"
        end
      end
    end

    describe "DELETE #destroy" do
      context "with a valid id" do
        let(:job) { FactoryGirl.create(:job) }
        before { delete :destroy, id: job.id }

        it "should destroy the corresponding job" do
          expect(Job.find_by_id(job.id)).to be_nil
        end

        it "should define a success flash message" do
          expect(flash[:success]).to_not be_nil
        end

        include_examples "redirect to", "index", "jobs_path"
      end
    end

    describe "GET #toggle_status" do
      context "with a valid id" do
        context "when the job is active" do
          let(:job) { FactoryGirl.create(:job, active: true) }
          before { get :toggle_status, id: job.id }

          it "should desactivate the job" do
            expect(job.reload.active).to be_false
          end
          include_examples "redirect to", "index", "jobs_path"
        end

        context "when the job is inactive" do
          let(:job) { FactoryGirl.create(:job, active: false) }
          before { get :toggle_status, id: job.id }

          it "should activate the job" do
            expect(job.reload.active).to be_true
          end
          include_examples "redirect to", "index", "jobs_path"
        end
      end
    end

    describe "GET #sort" do
      JOBS_SORTING_COLS.each do |col|
        context "on the #{col} column" do
          context "when the column has no sort predefined" do
            before do
              session[:jobs] = { sort: {field: JOBS_SORTING_COLS.clone.delete(col).first, type: "asc"},
                per_page: JOBS_DEFAULT_PER_PAGE }
              get :sort, field: col
            end

            it "should save an ascending sort" do
              expect(session[:jobs][:sort]).to eq({field: col, type: "asc"})
            end
            include_examples "redirect to", "index", "jobs_path"
          end

          context "when the column has already an ascending sort" do
            before do
              session[:jobs] = { sort: {field: col, type: "asc"},
                per_page: JOBS_DEFAULT_PER_PAGE }
              get :sort, field: col
            end

            it "should save a descending sort" do
              expect(session[:jobs][:sort]).to eq({field: col, type: "desc"})
            end
            include_examples "redirect to", "index", "jobs_path"
          end

          context "when the column has already a descending sort" do
            before do
              session[:jobs] = { sort: {field: col, type: "desc"},
                per_page: JOBS_DEFAULT_PER_PAGE }
              get :sort, field: col
            end

            it "should save a ascending sort" do
              expect(session[:jobs][:sort]).to eq({field: col, type: "asc"})
            end
            include_examples "redirect to", "index", "jobs_path"
          end
        end
      end
    end

    describe "GET #per_page" do
      JOBS_PER_PAGE.each do |number|
        if number == "all"
          context "when the number is <all>" do
            before { get :per_page, number: number }

            it "should save all elements to display per page" do
              expect(session[:jobs][:per_page]).to eq Job.count
            end
            include_examples "redirect to", "index", "jobs_path"
          end
        else
          context "when the number is #{number}" do
            before { get :per_page, number: number }

            it "should save #{number} elements to display per page" do
              expect(session[:jobs][:per_page]).to eq number
            end
            include_examples "redirect to", "index", "jobs_path"
          end
        end
      end
    end
  end
end