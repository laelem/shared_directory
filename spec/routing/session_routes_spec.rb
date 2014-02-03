require 'spec_helper'

describe "Session" do

  it "should have routing for only new/create/destroy actions" do
    assert_recognizes({ controller: 'sessions', action: 'new'    }, { path: 'sessions/new', method: :get })
    assert_recognizes({ controller: 'sessions', action: 'create' }, { path: 'sessions', method: :post })
    assert_recognizes({ controller: 'sessions', action: 'destroy', id: '1' }, { path: 'sessions/1', method: :delete })
    expect(get: "/sessions").not_to be_routable
    expect(get: "/sessions/1").not_to be_routable
    expect(get: "/sessions/1/edit").not_to be_routable
    expect(put: "/sessions/1").not_to be_routable
    expect(patch: "/sessions/1").not_to be_routable
  end

  it "should have custom path for signin/signout actions" do
    assert_routing({ path: 'signin', method: :get },
      { controller: 'sessions', action: 'new' })
    assert_routing({ path: 'signout', method: :delete },
      { controller: 'sessions', action: 'destroy' })
  end

  describe "routes with param" do
    describe "id" do
      context "when id is not a number" do
        it "should not be routable" do
          expect(delete: "/sessions/aa").not_to be_routable
        end
      end
    end
  end
end