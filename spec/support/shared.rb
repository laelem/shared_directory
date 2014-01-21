shared_examples_for "a protected controller" do |controller, item, except|
  subject { page }

  if except.nil? or except.exclude? 'index'
    describe "visiting the index page" do
      before { visit eval(controller + 's_path') }
      it { should have_title('Sign in') }
    end
  end

  if except.nil? or except.exclude? 'show'
    describe "visiting the show page" do
      before { visit eval(controller + '_path(item)') }
      it { should have_title('Sign in') }
    end
  end

  if except.nil? or except.exclude? 'new'
    describe "visiting the creation page" do
      before { visit eval('new_' + controller + '_path') }
      it { should have_title('Sign in') }
    end
  end

  if except.nil? or except.exclude? 'create'
    describe "submitting to the create action" do
      before { post eval(controller + 's_path') }
      specify { expect(response).to redirect_to(signin_path) }
    end
  end

  if except.nil? or except.exclude? 'edit'
    describe "visiting the edit page" do
      before { visit eval('edit_' + controller + '_path(item)') }
      it { should have_title('Sign in') }
    end
  end

  if except.nil? or except.exclude? 'update'
    describe "submitting to the update action" do
      before { patch eval(controller + '_path(item)') }
      specify { expect(response).to redirect_to(signin_path) }
    end
  end

  if except.nil? or except.include? 'delete'
    describe "submitting to the delete action" do
      before { delete eval(controller + '_path(item)') }
      specify { expect(response).to redirect_to(signin_path) }
    end
  end
end

shared_examples_for "a required data" do |data, confirmation=false|
  context "when #{data} is not set" do
    if confirmation then before { @obj.send("#{data}_confirmation=", nil) } end
    before { @obj.send("#{data}=", nil) }
    it { should_not be_valid }
  end
end

shared_examples_for "a non-blank data" do |data, confirmation=false|
  it_should_behave_like "a required data", data, confirmation
  context "when #{data} is empty" do
    if confirmation then before { @obj.send("#{data}_confirmation=", " ") } end
    before { @obj.send("#{data}=", " ") }
    it { should_not be_valid }
  end
end

shared_examples_for "a unique data" do |data, case_sensitive=false, confirmation=false|
  context "when #{data} already exists" do
    error_message = "has already been taken"
    before do
      obj_with_same_data = @obj.clone
      unless case_sensitive
        data_upcased = @obj.send("#{data}").upcase
        if confirmation then @obj.send("#{data}_confirmation=", data_upcased) end
        @obj.send("#{data}=", data_upcased)
      end
      obj_with_same_data.save
    end

    it "should not be valid and render the error : #{error_message}" do
      expect(@obj).to_not be_valid
      expect(@obj.errors["#{data}".to_sym]).to include(error_message)
    end
  end
end

shared_examples_for "a data that contains only alphabetic characters" do |data|
# including spaces, dashes and simple quotes

  context "when #{data} contains invalid characters" do
    it "should not be valid" do
      datas = ['22222', 'aaaa2', 'aa2aa', 'aa_aa', 'aaaa?', 'aaéçâ']
      datas.each do |invalid_data|
        @obj.send("#{data}=", invalid_data)
        expect(@obj).to_not be_valid
        expect(@obj.errors["#{data}".to_sym]).to include("is invalid")
      end
    end
  end

  context "when #{data} contains valid characters" do
    it "should be valid" do
      datas = ['aaaaa', 'aa aaaa', 'aa-aa', 'aa\'aa']
      datas.each do |valid_data|
        @obj.send("#{data}=", valid_data)
        expect(@obj).to be_valid
      end
    end
  end
end

shared_examples_for "a data with a minimal length" do |data, min_size, confirmation=false|
  context "when #{data} is too short" do
    error_message = "is too short (minimum is #{min_size} characters)"
    it "should not be valid and render the error: #{error_message}" do
      datas = ["a" * (min_size - 1), " " + "a" * (min_size - 1),
        " " + "a" * (min_size - 2) + " ", "a" * (min_size - 1) + " "]
      datas.each do |invalid_data|
        if confirmation then @obj.send("#{data}_confirmation=", invalid_data) end
        @obj.send("#{data}=", invalid_data)
        expect(@obj).to_not be_valid
        expect(@obj.errors["#{data}".to_sym]).to include(error_message)
      end
    end
  end

  context "when name has the minimal length (#{min_size})" do
    before do
      @obj.send("#{data}=", "a" * min_size )
      if confirmation then @obj.send("#{data}_confirmation=", "a" * min_size) end
    end
    it { should be_valid }
  end
end

shared_examples_for "a data with a maximal length" do |data,
  max_size=MAX_SIZE_DEFAULT_INPUT_TEXT, confirmation=false|

  context "when #{data} is too long" do
    error_message = "is too long (maximum is #{max_size} characters)"
    before do
      @obj.send("#{data}=", "a" * (max_size + 1))
      if confirmation then @obj.send("#{data}_confirmation=", "a" * (max_size + 1)) end
    end
    it "should not be valid and render the error : #{error_message}" do
      expect(@obj).to_not be_valid
      expect(@obj.errors["#{data}".to_sym]).to include(error_message)
    end
  end

  context "when #{data} has the maximal length (#{max_size})" do
    it "should be valid" do
      datas = ["a" * max_size, " " + "a" * max_size,
        " " + "a" * max_size + " ", "a" * max_size + " "]
      datas.each do |valid_data|
        if confirmation then @obj.send("#{data}_confirmation=", valid_data) end
        @obj.send("#{data}=", valid_data)
        expect(@obj).to be_valid
      end
    end
  end
end

shared_examples_for "a data with an exact length" do |data, size, confirmation=false|

  context "when #{data} has the wrong length" do
    error_message = "is the wrong length (should be #{size} characters)"
    it "should not be valid and render the error : #{error_message}" do
      datas = ["a" * (size+1), "a" * (size-1), " " + "a" * (size-1) + " a"]
      datas.each do |invalid_data|
        if confirmation then @obj.send("#{data}_confirmation=", invalid_data) end
        @obj.send("#{data}=", invalid_data)
        expect(@obj).to_not be_valid
        expect(@obj.errors["#{data}".to_sym]).to include(error_message)
      end
    end
  end

  context "when #{data} has the right length" do
    it "should be valid" do
      datas = ["a" * size, " " + "a" * size, " " + "a" * size + " ", "a" * size + " "]
      datas.each do |valid_data|
        if confirmation then @obj.send("#{data}_confirmation=", valid_data) end
        @obj.send("#{data}=", valid_data)
        expect(@obj).to be_valid
      end
    end
  end
end

shared_examples_for "a data that accepts only few values" do |data, wrong_value|
  context "when #{data} value is not permitted" do
    before { @obj.send("#{data}=", wrong_value) }
    it "should not be valid and render the error : is not included in the list" do
      expect(@obj).to_not be_valid
      expect(@obj.errors["#{data}".to_sym]).to include("is not included in the list")
    end
  end
end

shared_examples_for "a data with a valid date format" do |data|
  error_message = "is not a valid date"

  context "when #{data} has not the right format" do
    it "should not be valid and render the error : #{error_message}" do
      datas = %w[aaa 222 aa/aa/aaaa 01-01-2010 1a/11/2010 01/01/10]
      datas.each do |invalid_data|
        @obj.send("#{data}=", invalid_data)
        expect(@obj).to_not be_valid
        expect(@obj.errors["#{data}_before_type_cast".to_sym]).to include(error_message)
      end
    end
  end

  context "when #{data} takes impossible values" do
    it "should not be valid and render the error : #{error_message}" do
      datas = %w[32/01/2010 31/02/2010 01/13/2010 29/02/2010 30/02/2012]
      datas.each do |invalid_data|
        @obj.send("#{data}=", invalid_data)
        expect(@obj).to_not be_valid
        expect(@obj.errors["#{data}_before_type_cast".to_sym]).to include(error_message)
      end
    end
  end

  context "when #{data} takes right values" do
    it "should be valid" do
      datas = ["29/01/2012", "31/12/2010", "01/01/2010", " 01/01/2010 "]
      datas.each do |valid_data|
        @obj.send("#{data}=", valid_data)
        expect(@obj).to be_valid
      end
    end
  end
end

shared_examples_for "a stripped data" do |data|
  before { @obj.send("#{data}=", "   aa   aa   ") }
  it "should be stripped before validation" do
    @obj.valid?
    unless @obj.respond_to?("#{data}_before_type_cast")
      expect(@obj.send("#{data}")).to eq "aa   aa"
    else
      expect(@obj.send("#{data}_before_type_cast")).to eq "aa   aa"
    end
  end
end

shared_examples_for "a squished data" do |data|
  before { @obj.send("#{data}=", "   aa     aa   ") }
  it "should be squished before validation" do
    @obj.valid?
    unless @obj.respond_to?("#{data}_before_type_cast")
      expect(@obj.send("#{data}")).to eq "aa aa"
    else
      expect(@obj.send("#{data}_before_type_cast")).to eq "aa aa"
    end
  end
end