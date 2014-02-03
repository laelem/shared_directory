require 'spec_helper'

describe "Authentication" do

  subject { page }

  describe "signin" do
    before { visit signin_path }

    describe "with invalid information" do

      shared_examples_for "an invalid signin" do
        it { should have_title('Sign in') }

        describe "after visiting another page" do
          before { click_link "Shared directory" }
          it { should_not have_selector(CLASS_ERROR) }
        end
      end

      context "with all fields blank" do
        before { click_button "Sign in" }
        it { should have_error_message('Email and password can\'t be blank') }
        it_should_behave_like "an invalid signin"
      end

      context "with email blank" do
        before do
          fill_in "Password", with: "foobar"
          click_button "Sign in"
        end
        it { should have_error_message('Email can\'t be blank') }
        it_should_behave_like "an invalid signin"
      end

      context "with password blank" do
        before do
          fill_in "Email", with: "foobar"
          click_button "Sign in"
        end
        it { should have_error_message('Password can\'t be blank') }
        it_should_behave_like "an invalid signin"
      end

      context "with an invalid email format" do
        before do
          fill_in "Email", with: "foobar"
          fill_in "Password", with: "foobar"
          click_button "Sign in"
        end
        it { should have_error_message('Email is invalid') }
        it_should_behave_like "an invalid signin"
      end

      context "with an inexistant email" do
        before do
          fill_in "Email", with: "wrong_email@example.com"
          fill_in "Password", with: "foobar"
          click_button "Sign in"
        end
        it { should have_error_message('Invalid email/password combination') }
        it_should_behave_like "an invalid signin"
      end

      context "with a right email but a wrong password" do
        let(:user) { FactoryGirl.create(:user) }
        before do
          fill_in "Email", with: user.email
          fill_in "Password", with: "wrong_password"
          click_button "Sign in"
        end
        it { should have_error_message('Invalid email/password combination') }
        it_should_behave_like "an invalid signin"
      end
    end

    context "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before do
        fill_in "Email", with: user.email
        fill_in "Password", with: user.password
        click_button "Sign in"
      end

      it { should have_link('Sign out', href: signout_path) }
    end
  end

  describe "authorization" do

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "visiting a page" do
        before { visit root_url }
        it { should_not have_link('Jobs',       href: jobs_path) }
        it { should_not have_link('Users',      href: users_path) }
        it { should_not have_link('Contacts',   href: contacts_path) }
        it { should_not have_link('Sign out',   href: sign_out_path) }
      end

      describe "when attempting to visit a protected page" do
        before do
          visit jobs_path
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do

          it "should render the desired protected page" do
            expect(page).to have_title('List of jobs')
          end

          describe "when signing in again" do
            before do
              delete signout_path
              sign_in user
            end

            it "should render the default welcome page" do
              expect(page).to have_title('Shared directory')
              expect(page).to have_content('Welcome')
            end
          end
        end
      end

      describe "in the Jobs controller" do
        let(:item) { FactoryGirl.create(:job) }
        it_should_behave_like "a protected controller", "job", :item, %w(show)
      end

      describe "in the Users controller" do
        let(:item) { user }
        it_should_behave_like "a protected controller", "user", :item
      end

      describe "in the Contacts controller" do
        let(:item) { FactoryGirl.create(:contact) }
        it_should_behave_like "a protected controller", "contact", :item
      end
    end

    # describe "for signed-in users" do
    #   let(:user) { FactoryGirl.create(:user) }
    #   before { sign_in user, no_capybara: true }

    #   describe "in the Users controller" do

    #     describe "submitting a GET request to the Users#new action" do
    #       before { get new_user_path }
    #       specify { expect(response).to redirect_to(root_url) }
    #     end

    #     describe "submitting a POST request to the Users#create action" do
    #       before { post users_path }
    #       specify { expect(response).to redirect_to(root_url) }
    #     end
    #   end
    # end

    # describe "as wrong user" do
    #   let(:user) { FactoryGirl.create(:user) }
    #   let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
    #   before { sign_in user, no_capybara: true }

    #   describe "visiting Users#edit page" do
    #     before { visit edit_user_path(wrong_user) }
    #     it { should_not have_title(full_title('Edit user')) }
    #   end

    #   describe "submitting a PATCH request to the Users#update action" do
    #     before { patch user_path(wrong_user) }
    #     specify { expect(response).to redirect_to(root_url) }
    #   end
    # end

    # describe "as non-admin user" do
    #   let(:user) { FactoryGirl.create(:user) }
    #   let(:non_admin) { FactoryGirl.create(:user) }

    #   before { sign_in non_admin, no_capybara: true }

    #   describe "submitting a DELETE request to the Users#destroy action" do
    #     before { delete user_path(user) }
    #     specify { expect(response).to redirect_to(root_url) }
    #   end
    # end

    # describe "as admin user" do
    #   let(:admin) { FactoryGirl.create(:admin) }

    #   before { sign_in admin, no_capybara: true }

    #   describe "attempting to destroy himself" do
    #     it "should not delete his account" do
    #       expect { delete user_path(admin) }.not_to change(User, :count)
    #     end
    #   end
    # end
  end
end