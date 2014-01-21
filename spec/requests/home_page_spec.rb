require 'spec_helper'

describe "Home page" do

  subject { page }

  describe "for non-signed-in users" do
    before { visit root_url }
    specify { expect(response).to redirect_to(signin_path) }
  end

  describe "for signed-in users" do

  end
end