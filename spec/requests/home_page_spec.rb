require 'spec_helper'

describe "Home page" do

  subject { page }

  describe "for non-signed-in users" do
    before { visit root_path }
    specify { expect(response).to redirect_to(signin_path) }
  end

  describe "for signed-in users" do
    before { visit root_path }
    it { should have_content('Welcome') }
  end
end