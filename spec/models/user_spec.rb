require 'spec_helper'

describe User do

  before do
    @user = @obj = User.simple_valid_record
  end

  subject { @user }

  it { should respond_to(:email) }
  it { should respond_to(:email_confirmation) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:active) }
  it { should respond_to(:admin) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authenticate) }

  it { should be_valid }
  it { should be_active }
  it { should_not be_admin }

  describe "email" do
    it_should_behave_like "a stripped data", "email"
    it_should_behave_like "a non-blank data", "email", confirmation: true
    it_should_behave_like "a unique data", "email", confirmation: true

    context "when email is too long" do
      error_message = "is too long (maximum is #{MAX_SIZE_DEFAULT_INPUT_TEXT} characters)"
      before { @user.email = @user.email_confirmation \
                           = "a" * MAX_SIZE_DEFAULT_INPUT_TEXT + "@example.com" }
      it "should not be valid and render the error : #{error_message}" do
        expect(@user).to_not be_valid
        expect(@user.errors[:email]).to include(error_message)
      end
    end

    context "when email has the maximal length (#{MAX_SIZE_DEFAULT_INPUT_TEXT})" do
      it "should be valid" do
        datas = ["a" * (MAX_SIZE_DEFAULT_INPUT_TEXT - 12) + "@example.com",
          " " + "a" * (MAX_SIZE_DEFAULT_INPUT_TEXT - 13) + "@example.com",
          " " + "a" * (MAX_SIZE_DEFAULT_INPUT_TEXT - 14) + "@example.com ",
          "a" * (MAX_SIZE_DEFAULT_INPUT_TEXT - 14) + "@example.com "]
        datas.each do |valid_data|
          @user.email = @user.email_confirmation = valid_data
          expect(@obj).to be_valid
        end
      end
    end

    context "when email format is invalid" do
      it "should not be valid" do
        addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                       foo@bar_baz.com foo@bar+baz.com foo@bar..com]
        addresses.each do |invalid_address|
          @user.email = @user.email_confirmation = invalid_address
          expect(@user).not_to be_valid
          expect(@user.errors[:email]).to include("is invalid")
        end
      end
    end

    context "when email format is valid" do
      it "should be valid" do
        addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
        addresses.each do |valid_address|
          @user.email = @user.email_confirmation = valid_address
          expect(@user).to be_valid
        end
      end
    end

    describe "save format" do
      let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

      it "should be saved as all lower-case" do
        @user.email = @user.email_confirmation = mixed_case_email
        @user.save
        expect(@user.reload.email).to eq mixed_case_email.downcase
      end
    end
  end

  describe "email confirmation" do
    it_should_behave_like "a stripped data", "email_confirmation"
    it_should_behave_like "a required data", "email_confirmation"

    context "when email doesn't match confirmation" do
      error_message = "doesn't match Email"
      before { @user.email_confirmation = "mismatch@example.com" }
      it "should not be valid and render the error: #{error_message}" do
        expect(@user).to_not be_valid
        expect(@user.errors[:email_confirmation]).to include(error_message)
      end
    end
  end

  describe "password" do
    it_should_behave_like "a stripped data", "password"
    it_should_behave_like "a non-blank data", "password", confirmation: true
    it_should_behave_like "a data with a minimal length", "password",
      MIN_SIZE_USER_PASSWORD, confirmation: true
    it_should_behave_like "a data with a maximal length", "password",
      MAX_SIZE_USER_PASSWORD, confirmation: true
  end

  describe "password confirmation" do
    it_should_behave_like "a stripped data", "password_confirmation"
    it_should_behave_like "a required data", "password_confirmation"

    context "when password doesn't match confirmation" do
      error_message = "doesn't match Password"
      before { @user.password_confirmation = "mismatch" }
      it "should not be valid and render the error: #{error_message}" do
        expect(@user).to_not be_valid
        expect(@user.errors[:password_confirmation]).to include(error_message)
      end
    end
  end

  describe "first name" do
    it_should_behave_like "a squished data", "first_name"
    it_should_behave_like "a non-blank data", "first_name"
    it_should_behave_like "a data that contains only alphabetic characters", "first_name"
    it_should_behave_like "a data with a maximal length", "first_name", MAX_SIZE_USER_FIRST_NAME

    describe "save format" do
      let(:mixed_case_first_name) { "jEaN pHiLiPpe" }

      it "should be saved with only first letters of each word upcased" do
        @user.first_name = mixed_case_first_name
        @user.save
        expect(@user.reload.first_name).to eq "Jean Philippe"
      end
    end
  end

  describe "last name" do
    it_should_behave_like "a squished data", "last_name"
    it_should_behave_like "a non-blank data", "last_name"
    it_should_behave_like "a data that contains only alphabetic characters", "last_name"
    it_should_behave_like "a data with a maximal length", "last_name", MAX_SIZE_USER_LAST_NAME

    describe "save format" do
      let(:mixed_case_last_name) { "dU lAc" }

      it "should be saved with only first letters of each word upcased" do
        @user.last_name = mixed_case_last_name
        @user.save
        expect(@user.reload.last_name).to eq "Du Lac"
      end
    end
  end

  describe "active status" do
    it_should_behave_like "a required data", "active"

    context "with active attribute set to 'false'" do
      before do
        @user.save!
        @user.toggle!(:active)
      end

      it { should_not be_active }
    end
  end

  describe "admin" do
    it_should_behave_like "a required data", "admin"

    context "with admin attribute set to 'true'" do
      before do
        @user.save!
        @user.toggle!(:admin)
      end

      it { should be_admin }
    end
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    context "with valid password" do
      it { should == found_user.authenticate(@user.password) }
    end

    context "with invalid password" do
      let(:user_for_invalid_password) { found_user.authenticate("invalid") }

      it { should_not == user_for_invalid_password }
      specify { user_for_invalid_password.should be_false }
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end

end