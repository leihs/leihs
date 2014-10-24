Given /^test data setup for =Provision of accessible fields= feature$/ do
  @inventory_pool = FactoryGirl.create :inventory_pool
  @minimum_field_size = Field.where(:permissions => nil).size
end

Given /^a user with role (\w+) exists$/ do |manager_role|
  @user = FactoryGirl.create(:user)
  @manager_role = manager_role.to_sym
  @user.access_rights << FactoryGirl.create(:access_right, :role => @manager_role, :user => @user, :inventory_pool => @inventory_pool)
end

When /^you get the accessible fields for this user$/ do
  @accessible_fields = Field.all.select {|f| f.accessible_by? @user, @inventory_pool }
end

Then /^the user has access to at least all the fields without any permissions$/ do
  expect(@accessible_fields.size).to be >= @minimum_field_size
end

Then /^the amount of the accessible fields (.*) (\w+) can be different$/ do |compare_op, higher_manager_role|
  user_role = @user.access_right_for(@inventory_pool).role
  expect(user_role).to eq @manager_role
  user_role_level = AccessRight::ROLES_HIERARCHY.index user_role
  unless @accessible_fields.empty?
    @accessible_fields.each {|field|
      expect(AccessRight::ROLES_HIERARCHY.index(field[:permissions][:role])).to be <= user_role_level if field[:permissions] and field[:permissions][:role]
    }
  end

  # create a user with higher level
  @higher_user = FactoryGirl.create(:user)
  @higher_user.access_rights << FactoryGirl.create(:access_right, :role => higher_manager_role.to_sym, :user => @higher_user, :inventory_pool => @inventory_pool)
  # create also data for an higher level
  @higher_accessible_fields = Field.all.select {|f| f.accessible_by? @higher_user, @inventory_pool }
  # check that the same condition holds true also for higher level
  expect(@higher_accessible_fields.size).to be >= @minimum_field_size

  if compare_op == "equals"
    expect(@accessible_fields.size).to eq @higher_accessible_fields.size
  elsif compare_op == "less than"
    expect(@accessible_fields.size).to be < @higher_accessible_fields.size
  end
end

Given /^an item is existing$/ do
  @item = FactoryGirl.create :item
end

Then /^each field provides the value of the item's attribute$/ do
  Field.all.each do |field|
    expected_value = Array(field.attribute).inject(@item) do |r, m|
      if r.is_a?(Hash)
        r[m]
      else
        if m == "id"
          r
        else
          r.try(:send, m)
        end
      end
    end

    expect(field.value(@item)).to eq expected_value
  end
end

Then /^each field is capable of providing values even if its values attribute is a lambda\/proc$/ do
  Field.all.each do |field|
    if field.values
      expect(field.values).not_to be_nil
    end
  end
end
