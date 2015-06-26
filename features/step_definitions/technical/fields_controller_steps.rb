When /^the fields in json format are fetched via the index action$/ do
  response = get manage_fields_path(@current_inventory_pool, format: :json)
  @json = JSON.parse response.body
end

Then /^the accessible fields of the logged in user include each field from the json response$/ do
  accessible_fields = Field.all.select {|f| f.accessible_by? @current_user, @current_inventory_pool }
  accessible_fields_ids = accessible_fields.map &:id
  @json.each do |field|
    expect(accessible_fields_ids.include?(field['id'])).to be true
  end
end
