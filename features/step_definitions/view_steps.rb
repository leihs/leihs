#Then "$who sees '$what'" do | who, what |
#  @response.should have_tag("a", what)
#end

#Then "he sees the '$title' list" do | title |
#  response.should render_template("backend/#{title}/index")
#end

Then "I see the '$title' list" do | title |
  expect(has_selector?(".buttons .activated", :text => title)).to be true
  expect(has_selector?(".table-overview .fresh")).to be true

  expect(has_selector?(".contract")).to be true
end

Then /^(\w+) can "([^\"]*)"$/ do |who, what|
  @response.should have_tag("a", what)
end

When "lending_manager looks at the screen" do
  get manage_daily_view_path(@inventory_pool)
  @response = response
end

Then "it will fail with an error" do
  step "user sees an error message"
end

# Flash error message
Then "$who sees an error message" do |who|
  response.should have_tag('div.error')
end
