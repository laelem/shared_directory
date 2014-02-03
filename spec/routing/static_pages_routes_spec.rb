require 'spec_helper'

describe "Static pages" do
  it "should have route for home page" do
    assert_routing({ path: '/', method: :get }, { controller: 'static_pages', action: 'home' })
  end
end