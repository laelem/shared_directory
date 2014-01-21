require 'spec_helper'
require 'RMagick'
include Magick

describe Contact do

  before do
    @contact = @obj = Contact.simple_valid_record
  end

  subject { @contact }

  it { should respond_to(:active) }
  it { should respond_to(:civility) }
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:date_of_birth) }
  it { should respond_to(:date_of_birth_before_type_cast) }

  it { should respond_to(:address) }
  it { should respond_to(:zip_code) }
  it { should respond_to(:city) }
  it { should respond_to(:country) }
  it { should respond_to(:phone_number) }
  it { should respond_to(:mobile_number) }
  it { should respond_to(:email) }

  it { should be_valid }
  it { should be_active }

  describe "active status" do
    it_should_behave_like "a required data", "active"

    context "with active attribute set to 'false'" do
      before do
        @contact.save!
        @contact.toggle!(:active)
      end

      it { should_not be_active }
    end
  end

  describe "civility" do
    it_should_behave_like "a required data", "civility"
    it_should_behave_like "a data that accepts only few values", "civility", "Dr"
  end

  describe "first name" do
    it_should_behave_like "a squished data", "first_name"
    it_should_behave_like "a non-blank data", "first_name"
    it_should_behave_like "a data that contains only alphabetic characters", "first_name"
    it_should_behave_like "a data with a minimal length", "first_name", MIN_SIZE_CONTACT_FIRST_NAME
    it_should_behave_like "a data with a maximal length", "first_name", MAX_SIZE_CONTACT_FIRST_NAME

    describe "save format" do
      let(:mixed_case_name) { "jEaN eDoUaRd" }

      it "should be saved with only the first letter of each word upcased" do
        @contact.first_name = mixed_case_name
        @contact.save
        expect(@contact.reload.first_name).to eq "Jean Edouard"
      end
    end
  end

  describe "last name" do
    it_should_behave_like "a squished data", "last_name"
    it_should_behave_like "a non-blank data", "last_name"
    it_should_behave_like "a data that contains only alphabetic characters", "last_name"
    it_should_behave_like "a data with a minimal length", "last_name", MIN_SIZE_CONTACT_LAST_NAME
    it_should_behave_like "a data with a maximal length", "last_name", MAX_SIZE_CONTACT_LAST_NAME

    describe "save format" do
      let(:mixed_case_name) { "dU lAc" }

      it "should be saved with only the first letter of each word upcased" do
        @contact.last_name = mixed_case_name
        @contact.save
        expect(@contact.reload.last_name).to eq "Du Lac"
      end
    end
  end

  describe "date of birth" do
    it_should_behave_like "a stripped data", "date_of_birth"
    it_should_behave_like "a non-blank data", "date_of_birth"
    it_should_behave_like "a data with a valid date format", "date_of_birth"
  end

  describe "jobs" do

    context "when no job is present" do
      error_message = "can't be blank"
      before { @contact.jobs = [] }

      it "should not be valid and render the error : #{error_message}" do
        expect(@contact).to_not be_valid
        expect(@contact.errors[:jobs]).to include(error_message)
      end
    end

    context "when an invalid job is present" do
      error_message = "is invalid"
      before { @contact.jobs = [Job.new] }

      it "should not be valid and render the error : #{error_message}" do
        expect(@contact).to_not be_valid
        expect(@contact.errors[:jobs]).to include(error_message)
      end
    end

    context "when an inactive job is present" do
      error_message = "can't contain inactive jobs"
      let(:job) { Job.simple_valid_record }
      before do
        job.active = false
        @contact.jobs = [job]
      end

      it "should not be valid and render the error : #{error_message}" do
        expect(@contact).to_not be_valid
        expect(@contact.errors[:jobs]).to include(error_message)
      end
    end
  end

  describe "address" do
    it_should_behave_like "a stripped data", "address"
    it_should_behave_like "a data with a maximal length", "address"
  end

  describe "zip code" do
    it_should_behave_like "a stripped data", "zip_code"

    context "when zip code has not a valid format" do
      it "should not be valid" do
        datas = ["a", "aaaaa", "3aaaa", "a3333", "33 333", "3;;;3"]
        datas.each do |invalid_data|
          @contact.zip_code = invalid_data
          expect(@contact).to_not be_valid
          expect(@contact.errors[:zip_code]).to_not be_empty
        end
      end
    end
  end

  describe "city" do
    it_should_behave_like "a stripped data", "city"
    it_should_behave_like "a data with a maximal length", "city"

    describe "save format" do
      let(:mixed_case_city) { "tOrOntO tO" }

      it "should be saved with the first letter upcased" do
        @contact.city = mixed_case_city
        @contact.save
        expect(@contact.reload.city).to eq "TOrOntO tO"
      end
    end
  end

  describe "country" do
    error_message = "is invalid"

    context "when country is not valid" do
      let(:invalid_country) { Country.new }
      before { @contact.country = invalid_country }

      it "should not be valid and render the error: #{error_message}" do
        expect(@contact).to_not be_valid
        expect(@contact.errors[:country]).to include error_message
      end
    end
  end

  describe "phone number / mobile number" do
    it_should_behave_like "a squished data", "phone_number"
    it_should_behave_like "a squished data", "mobile_number"
    ["phone_number", "mobile_number"].each do |number|

      context "when #{number} has not a valid format" do
        it "should not be valid" do
          datas = ["a", "a"*10, "3"*11, "3"*9, "3333 33333", "3;;;;;;;;3"]
          datas.each do |invalid_data|
            @contact.send("#{number}=", invalid_data)
            expect(@contact).to_not be_valid
            expect(@contact.errors[number.to_sym]).to_not be_empty
          end
        end
      end

      context "when #{number} has a valid format" do
        it "should be valid" do
          @contact.send("#{number}=", "3"*10)
          expect(@contact).to be_valid
        end
      end
    end
  end

  describe "email" do
    it_should_behave_like "a stripped data", "email"
    it_should_behave_like "a non-blank data", "email"
    it_should_behave_like "a unique data", "email"

    context "when email is too long" do
      error_message = "is too long (maximum is #{MAX_SIZE_DEFAULT_INPUT_TEXT} characters)"
      before { @contact.email = "a" * MAX_SIZE_DEFAULT_INPUT_TEXT + "@example.com" }
      it "should not be valid and render the error : #{error_message}" do
        expect(@contact).to_not be_valid
        expect(@contact.errors[:email]).to include(error_message)
      end
    end

    context "when email has the maximal length (#{MAX_SIZE_DEFAULT_INPUT_TEXT})" do
      it "should be valid" do
        datas = ["a" * (MAX_SIZE_DEFAULT_INPUT_TEXT - 12) + "@example.com",
          " " + "a" * (MAX_SIZE_DEFAULT_INPUT_TEXT - 13) + "@example.com",
          " " + "a" * (MAX_SIZE_DEFAULT_INPUT_TEXT - 14) + "@example.com ",
          "a" * (MAX_SIZE_DEFAULT_INPUT_TEXT - 14) + "@example.com "]
        datas.each do |valid_data|
          @contact.email = valid_data
          expect(@obj).to be_valid
        end
      end
    end

    context "when email format is invalid" do
      it "should not be valid" do
        addresses = %w[contact@foo,com contact_at_foo.org example.contact@foo.
                       foo@bar_baz.com foo@bar+baz.com foo@bar..com]
        addresses.each do |invalid_address|
          @contact.email = invalid_address
          expect(@contact).not_to be_valid
          expect(@contact.errors[:email]).to_not be_empty
        end
      end
    end

    context "when email format is valid" do
      it "should be valid" do
        addresses = %w[contact@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
        addresses.each do |valid_address|
          @contact.email = valid_address
          expect(@contact).to be_valid
        end
      end
    end

    describe "save format" do
      let(:mixed_case_email) { "Foo@ExAMPle.CoM" }

      it "should be saved as all lower-case" do
        @contact.email = mixed_case_email
        @contact.save
        expect(@contact.reload.email).to eq "foo@example.com"
      end
    end
  end

  describe "photo" do

    context "when photo is blank" do
      before { @contact.upload_photo = " " }
      it { should be_valid }
    end

    context "when photo is not a file" do
      error_message = "is not a file"
      before { @contact.upload_photo = "aaa" }
      it "should not be valid and render the error : #{error_message}" do
        expect(@contact).to_not be_valid
        expect(@contact.errors[:photo]).to include(error_message)
      end
    end

    context "when photo is a directory" do
      error_message = "is not a file"
      it "should not be valid and render the error : #{error_message}" do
        File.open(".") do |f|
          @contact.upload_photo = f
          expect(@contact).to_not be_valid
          expect(@contact.errors[:photo]).to include(error_message)
        end
      end
    end

    context "when photo is not readable" do
      error_message = "is not readable"
      it "should not be valid and render the error : #{error_message}" do
        File.open(File.join(PATH_FAKE_FILES, 'no_type')) do |f|
          f.chmod(0333)
          @contact.upload_photo = f
          expect(@contact).to_not be_valid
          expect(@contact.errors[:photo]).to include(error_message)
          f.chmod(0664)
        end
      end
    end

    context "when photo has not a permitted extension" do
      error_message = "has a wrong type"
      it "should not be valid and render the error : #{error_message}" do
        File.open(File.join(PATH_FAKE_FILES, 'no_type.pdf')) do |f|
          @contact.upload_photo = f
          expect(@contact).to_not be_valid
          expect(@contact.errors[:photo].join).to match(Regexp.new('^'+error_message))
        end
      end
    end

    context "when photo has not a permitted content" do
      error_message = "has a wrong content"

      it "should not be valid and render the error : #{error_message}" do
        ['no_type.png', 'html.png'].each do |name|
          File.open(File.join(PATH_FAKE_FILES, name)) do |f|
            @contact.upload_photo = f
            expect(@contact).to_not be_valid
            expect(@contact.errors[:photo].join).to match(Regexp.new('^'+error_message))
          end
        end
      end
    end

    context "when photo is too large" do
      error_message = "is too large"
      it "should not be valid and render the error : #{error_message}" do
        File.open(File.join(PATH_FAKE_FILES, 'png_3Mb.png')) do |f|
          @contact.upload_photo = f
          expect(@contact).to_not be_valid
          expect(@contact.errors[:photo].join).to match(Regexp.new('^'+error_message))
        end
      end
    end

    context "when photo has the maximal size" do
      it "should be valid" do
        File.open(File.join(PATH_FAKE_FILES, 'png_2Mb.png')) do |f|
          @contact.upload_photo = f
          expect(@contact).to be_valid
        end
      end
    end

    describe "upload management" do
      let(:filepath) { Rails.root.join(UPLOAD_PATH_CONTACT_PHOTO, "image_*").to_s }

      context "when a new contact is created" do
        context "when no photo is present" do
          before do
            @contact.upload_photo = nil
            @contact.save
          end
          it "should have nil in the database" do
            expect(@contact.reload.photo).to eq nil
          end
        end

        context "when a photo is present" do
          before { @contact.upload_photo = File.open(File.join(PATH_FAKE_FILES, 'png.png')) }
          after { File.unlink @contact.photo }

          it "should save the file" do
            expect{@contact.save}.to change{Dir.glob(filepath).size}.by(1)
          end

          it "should have the filepath in the database" do
            @contact.save
            expect(@contact.reload.photo).to match /image_/
          end
        end
      end

      context "when a contact with photo is updated" do
        before do
          @contact.upload_photo = File.open(File.join(PATH_FAKE_FILES, 'png.png'))
          @contact.save
        end

        context "with no photo" do
          before { @contact.upload_photo = nil }

          it "should delete the file" do
            expect{@contact.save}.to change{Dir.glob(filepath).size}.by(-1)
          end

          it "should have nil in the database" do
            @contact.save
            expect(@contact.reload.photo).to eq nil
          end
        end
        context "with a new photo" do
          before { @contact.upload_photo = File.open(File.join(PATH_FAKE_FILES, 'png.png')) }
          after { File.unlink @contact.photo }

          it "should delete the previous file and save the new one" do
            expect{@contact.save}.to_not change{Dir.glob(filepath).size}.by(1)
            expect{@contact.save}.to_not change{Dir.glob(filepath).size}.by(-1)
          end

          it "should have the filepath in the database" do
            @contact.save
            expect(@contact.reload.photo).to match /image_/
          end
        end
      end

      context "when a contact with photo is deleted" do
        before do
          @contact.upload_photo = File.open(File.join(PATH_FAKE_FILES, 'png.png'))
          @contact.save
        end

        it "should delete the file" do
          expect{@contact.destroy}.to change{Dir.glob(filepath).size}.by(-1)
        end
      end

      describe "save format" do
        before do
          @contact.upload_photo = File.open(File.join(PATH_FAKE_FILES, 'png.png'))
          @contact.save
        end
        after { File.unlink @contact.photo }

        it "should be save the photo to fit in #{ROWS_IMG_CONTACT_PHOTO}*#{COLS_IMG_CONTACT_PHOTO}" do
          expect(Image.read(@contact.photo).first.rows).to eq ROWS_IMG_CONTACT_PHOTO
          expect(Image.read(@contact.photo).first.columns).to eq COLS_IMG_CONTACT_PHOTO
        end
      end
    end
  end

  describe "website" do
    it_should_behave_like "a stripped data", "website"

    context "when URL format is invalid" do
      it "should not be valid" do
        addresses = %w[mailto:user@example.com htttp//:www.google.com]
        addresses.each do |invalid_address|
          @contact.website = invalid_address
          expect(@contact).not_to be_valid
          expect(@contact.errors[:website]).to_not be_empty
        end
      end
    end

    context "when URL format is valid" do
      it "should be valid" do
        addresses = %w[http://www.google.com https://www.google.com]
        addresses.each do |valid_address|
          @contact.website = valid_address
          expect(@contact).to be_valid
        end
      end
    end
  end

  describe "comment" do
    it_should_behave_like "a stripped data", "comment"
    it_should_behave_like "a data with a maximal length", "comment", MAX_SIZE_CONTACT_COMMENT
  end

  describe "save format" do
    context "when string attributes are blank" do
      let(:string_attr) { %w(address zip_code city website comment phone_number mobile_number photo) }
      before do
        string_attr.each do |attr|
          @contact.send("#{attr}=", " ")
        end
        @contact.save
        @contact.reload
      end

      it "should save nil in database" do
        string_attr.each do |attr|
          expect(@contact.send("#{attr}")).to eq nil
        end
      end
    end
  end

end