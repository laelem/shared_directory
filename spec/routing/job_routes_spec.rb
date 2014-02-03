require 'spec_helper'

describe "Job" do

  it "should have routing for CRUD pages except the show one" do
    assert_routing({ path: 'jobs',        method: :get    }, { controller: 'jobs', action: 'index'  })
    assert_routing({ path: 'jobs/new',    method: :get    }, { controller: 'jobs', action: 'new'    })
    assert_routing({ path: 'jobs',        method: :post   }, { controller: 'jobs', action: 'create' })
    assert_routing({ path: 'jobs/1/edit', method: :get    }, { controller: 'jobs', action: 'edit',    id: '1' })
    assert_routing({ path: 'jobs/1',      method: :patch  }, { controller: 'jobs', action: 'update',  id: '1' })
    assert_routing({ path: 'jobs/1',      method: :put    }, { controller: 'jobs', action: 'update',  id: '1' })
    assert_routing({ path: 'jobs/1',      method: :delete }, { controller: 'jobs', action: 'destroy', id: '1' })
    expect(get: "/jobs/1").not_to be_routable
  end

  it "should have routing for pagination" do
    assert_routing({ path: 'jobs/page/1', method: :get },
      { controller: 'jobs', action: 'index', page: '1' })
  end

  it "should have routing for activate/desactivate actions" do
    assert_recognizes({ controller: 'jobs', action: 'toggle_status', id: '1'  },
      { path: 'jobs/1/activate', method: :get })
    assert_recognizes({ controller: 'jobs', action: 'toggle_status', id: '1'  },
      { path: 'jobs/1/desactivate', method: :get })
  end

  it "should have routing for column sorting" do
    JOBS_SORTING_COLS.each do |col|
      assert_routing({ path: "jobs/sort/#{col}", method: :get },
        { controller: 'jobs', action: 'sort', field: "#{col}" })
      assert_routing(sort_jobs_path(col),
        { controller: 'jobs', action: 'sort', field: "#{col}" })
    end
  end

  it "should have routing for per page elements number management" do
    JOBS_PER_PAGE.each do |number|
      assert_routing({ path: "jobs/per_page/#{number}", method: :get },
        { controller: 'jobs', action: 'per_page', number: "#{number}" })
      assert_routing(per_page_jobs_path(number),
        { controller: 'jobs', action: 'per_page', number: "#{number}" })
    end
  end

  describe "routes with param" do

    describe "id" do
      context "when id is not a number" do
        it "should not be routable" do
          expect(get: "/jobs/aa/edit").not_to be_routable
        end
      end
    end

    describe "page" do
      context "when page is not a number" do
        it "should not be routable" do
          expect(get: "/jobs/page/aa").not_to be_routable
        end
      end
    end

    describe "field" do
      context "when field is not in the list" do
        it "should not be routable" do
          expect(get: "/jobs/sort/inexistant_field").not_to be_routable
        end
      end
    end

    describe "number" do
      context "when number is not in the list" do
        it "should not be routable" do
          expect(get: "/jobs/per_page/inexistant_field").not_to be_routable
        end
      end
    end
  end
end