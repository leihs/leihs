def setup_user_with_access_level(level, type = nil)
  update_variable_name = lambda do |variable_name|
    "@" + (if type then type.to_s + "_" else "" end) + variable_name
  end

  instance_variable_set(update_variable_name.call("access_level"), level)
  instance_variable_set(update_variable_name.call("user"), FactoryGirl.create(:user))
  instance_variable_get(update_variable_name.call("user")).access_rights << FactoryGirl.create(:access_right,
                                                                                              :role => @role,
                                                                                              :user => instance_variable_get(update_variable_name.call("user")),
                                                                                              :access_level => instance_variable_get(update_variable_name.call("access_level")),
                                                                                              :inventory_pool => @inventory_pool)
end

Given /^test data setup for =Provision of accessible fields= feature$/ do
  @role = Role.create :name => "manager"
  @inventory_pool = FactoryGirl.create :inventory_pool
  @minimum_field_size = Field.where(:permissions => nil).size
end

Given /^an user with role manager and (\d+) exists$/ do |access_level|
  access_level = access_level.to_i
  setup_user_with_access_level(access_level)
  # create also data for an higher level which are needed in following steps
  setup_user_with_access_level(access_level + 1, :higher)
end

When /^you get the accessible fields for this user$/ do
  @accessible_fields = Field.accessible_by @user, @inventory_pool

  # create also data for an higher level which are needed in following steps
  @higher_accessible_fields = Field.accessible_by @higher_user, @inventory_pool
end

Then /^the user has access to at least all the fields without any permissions$/ do
  @accessible_fields.size.should >= @minimum_field_size
  # check that the same condition holds true also for higher access level
  @higher_accessible_fields.size.should >= @minimum_field_size
end

Then /^the amount of the accessible fields (.*) (\d+) can be different$/ do |compare_op, higher_access_level|
  unless @accessible_fields.empty?
    @access_level = 2 if @access_level == 1 # in leihs 3.0 we drop level 1 and we treat it as 2
    @accessible_fields.each {|field| field[:permissions][:level].should <= @access_level if field[:permissions] and field[:permissions][:level]}
  end

  @accessible_fields.size.should == @higher_accessible_fields.size if compare_op == "equals"
  @accessible_fields.size.should < @higher_accessible_fields.size if compare_op == "less than or equal to"
end

Given /^an item is existing$/ do
  @item = FactoryGirl.create :item
end

Then /^each field provides the value of the item's attribute$/ do
  Field.all.each do |field|
    field.value(@item).should == Array(field.attribute).inject(@item){|i,m| i.is_a?(Hash) ? OpenStruct.new(i).send(m) : i.send(m) }
  end
end

Then /^each field is capable of providing values even if its values attribute is a lambda\/proc$/ do
  Field.all.each do |field|
    if field.values
      field.values.should_not be_nil
    end
  end
end
