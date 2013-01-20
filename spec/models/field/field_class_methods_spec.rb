require 'spec_helper'

describe Field do

  describe "class methods" do
  
    context "accessible by " do
      
      it "provides just the fields that are available for the given user's level" do
        @role = Role.create :name => "manager"
        @inventory_pool = FactoryGirl.create :inventory_pool
        @minimum_field_size = Field.where(:permissions => nil).size

        def check_user_level(level)
          user = FactoryGirl.create :user
          user.access_rights << FactoryGirl.create(:access_right, :role => @role, :user => user, :access_level => level, :inventory_pool => @inventory_pool)
          accessible_fields = Field.accessible_by user, @inventory_pool
          accessible_fields.size.should >= @minimum_field_size
          unless accessible_fields.empty?
            level = 2 if level == 1 # in leihs 3.0 we drop level 1 and we treat it as 2
            accessible_fields.each {|field| field[:permissions][:level].should <= level if field[:permissions] and field[:permissions][:level]}
          end
          accessible_fields
        end

        accessible_fields_level_1 = check_user_level 1
        accessible_fields_level_2 = check_user_level 2
        accessible_fields_level_3 = check_user_level 3

        accessible_fields_level_1.size.should == accessible_fields_level_2.size # in leihs 3.0 we drop level 1 and we treat it as 2
        accessible_fields_level_2.size.should < accessible_fields_level_3.size
      end
    end
  end
end