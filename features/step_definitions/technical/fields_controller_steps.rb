When /^the fields in json format are fetched via the index action$/ do
  response = get backend_fields_path, format: :json, inventory_pool_id: @current_inventory_pool.id
  @json = JSON.parse response.body
end

Then /^the accessible fields of the logged in user include each field from the json response$/ do
  accessible_fields = Field.accessible_by @current_user, @current_inventory_pool
  accessible_fields_ids = accessible_fields.map(&:id)
  @json.each do |field|
    accessible_fields_ids.include?(field["id"]).should be_true
  end
end
