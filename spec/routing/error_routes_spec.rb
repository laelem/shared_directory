require 'spec_helper'

describe "Error" do

  it "should have routing for custom error pages : 404, 422, 500" do
    assert_routing({ path: '404', method: :get }, { controller: 'errors', action: 'not_found' })
    assert_recognizes({ controller: 'errors', action: 'server_error' }, { path: '500', method: :get })
    assert_recognizes({ controller: 'errors', action: 'server_error' }, { path: '422', method: :get })
  end
end