require 'spec_helper'

describe Country do

  before do
    @country = @obj = Country.simple_valid_record
  end

  subject { @country }

  it { should respond_to(:code) }
  it { should respond_to(:name) }

  it { should be_valid }

  describe "code" do
    it_should_behave_like "a squished data", "code"
    it_should_behave_like "a non-blank data", "code"
    it_should_behave_like "a data with an exact length", "code", SIZE_COUNTRY_CODE
    it_should_behave_like "a unique data", "code"

    context "when code contains non-alphabetic characters (including spaces)" do
      it "should not be valid" do
        datas = ["a2", "2a", "a;", " a", "a "]
        datas.each do |invalid_data|
          @country.code = invalid_data
          expect(@country).to_not be_valid
          expect(@country.errors[:code]).to_not be_empty
        end
      end
    end

    describe "save format" do
      let(:downcase_code) { "zx" }

      it "should be saved all upper-case" do
        @country.code = downcase_code
        @country.save
        expect(@country.reload.code).to eq "ZX"
      end
    end
  end

  describe "name" do
    it_should_behave_like "a squished data", "name"
    it_should_behave_like "a non-blank data", "name"
    it_should_behave_like "a data with a minimal length", "name", MIN_SIZE_COUNTRY_NAME
    it_should_behave_like "a data with a maximal length", "name", MAX_SIZE_DEFAULT_INPUT_TEXT
    it_should_behave_like "a unique data", "name"

    describe "save format" do
      let(:mixed_case_name) { "abC ygH" }
      it "should be saved with only the first letter upcased" do
        @country.name = mixed_case_name
        @country.save
        expect(@country.reload.name).to eq "AbC ygH"
      end
    end
  end
end