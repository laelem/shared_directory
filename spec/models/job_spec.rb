require 'spec_helper'

describe Job do

  before do
    @job = @obj = FactoryGirl.build(:job)
  end

  subject { @job }

  it { should respond_to(:name) }
  it { should respond_to(:active) }

  it { should be_valid }
  it { should be_active }

  describe "name" do
    it_should_behave_like "a squished data", "name"
    it_should_behave_like "a non-blank data", "name"
    it_should_behave_like "a unique data", "name", model: :job
    it_should_behave_like "a data that contains only alphabetic characters", "name"
    it_should_behave_like "a data with a minimal length", "name", MIN_SIZE_JOB_NAME
    it_should_behave_like "a data with a maximal length", "name"

    describe "save format" do
      let(:mixed_case_name) { "dEvElOpEr WEb" }

      it "should be saved with only the first letter upcased" do
        @job.name = mixed_case_name
        @job.save
        expect(@job.reload.name).to eq "Developer web"
      end
    end
  end

  describe "active status" do
    it_should_behave_like "a required data", "active"

    context "with active attribute set to 'false'" do
      before do
        @job.save!
        @job.toggle!(:active)
      end

      it { should_not be_active }
    end
  end
end