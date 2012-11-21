require 'spec_helper'

describe Field do

  describe "instance methods" do
  
    context "value" do
      
      it "provides the value of an item's attribute that is specified in the field" do
        item = FactoryGirl.create :item
        Field.all.each do |field|
          field.value(item).should == Array(field.attribute).inject(item){|i,m| i.is_a?(Hash) ? OpenStruct.new(i).send(m) : i.send(m) }
        end
      end

      it "provides values even if the values attribute of a field is a lambda/proc" do
        Field.all.each do |field|
          if field.values
            field.values.should_not be_nil
          end
        end
      end
    end
  end
end