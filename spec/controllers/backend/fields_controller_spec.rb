require 'spec_helper'

describe Backend::FieldsController do
  render_views
  
  before :all do
    role = Role.create(:name => "manager")
    @lending_manager = FactoryGirl.create :user
    @inventory_pool = FactoryGirl.create :inventory_pool
    @lending_manager.access_rights << FactoryGirl.create(:access_right, :user => @lending_manager, :inventory_pool => @inventory_pool, :role => role)
  end

  let :session do
    {user_id: @lending_manager.id}
  end

  describe "index" do

    it "provides accessible fields" do
      get :index, {format: "json", inventory_pool_id: @inventory_pool.id}, session
      json = JSON.parse response.body
      accessible_fields = Field.accessible_by @lending_manager, @inventory_pool
      accessible_fields_ids = accessible_fields.map(&:id)
      json.each do |field|
        accessible_fields_ids.include?(field["id"]).should be_true
      end
    end
  end
end