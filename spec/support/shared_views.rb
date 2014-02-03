shared_examples "job form template" do
  describe "fields" do
    FactoryGirl.attributes_for(:job, :sample).keys.each do |attribute|
      it { should have_selector "label", text: attribute.to_s.capitalize }
      it { should have_selector "input[name='job[#{attribute.to_s}]']" }
    end
  end

  describe "actions" do
    it { should have_submit_button "Save" }
    it { should have_link "Back" }
  end
end

shared_examples "job form requests" do |title, success_message|
  context "when he clicks on the Save button" do
    context "with valid attributes" do
      before do
        fill_in "Name", with: "Magician"
        click_button "Save"
      end

      it { should have_title "List of jobs" }
      it { should have_selector ".alert-success", text: success_message }
    end

    context "with invalid attributes" do
      context "with one error" do
        before do
          fill_in "Name", with: "De"
          click_button "Save"
        end

        it { should have_title title }
        within(:css, ".alert-error") do
          it { should have_content "1 error" }
          it { should_not have_content "1 errors" }
          it { should have_selector "li", text: "Name", count: 1 }
        end
      end

      context "with 2 errors on the same attribute" do
        before do
          fill_in "Name", with: ""
          click_button "Save"
        end

        it { should have_title title }
        within(:css, ".alert-error") do
          it { should have_content "1 error" }
          it { should_not have_content "1 errors" }
          it { should have_selector "li", text: "Name", count: 1 }
        end
      end
    end

    context "when he clicks on the Back button" do
      before { click_link "Back" }
      it { should have_title "List of jobs" }
    end
  end
end
