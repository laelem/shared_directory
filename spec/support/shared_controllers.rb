shared_examples "render view" do |template|
  it "should render the #{template} view" do
    expect(response).to render_template("#{template}")
  end
end

shared_examples "redirect to" do |page, path|
  it "should redirect to the #{page} page" do
    expect(response).to redirect_to eval(path)
  end
end
