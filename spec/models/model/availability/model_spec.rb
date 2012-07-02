require 'spec_helper'

describe Model do
  
  before :all do
    Persona.create_all
    @normin = Persona.get "Normin"
    #@petra = Persona.get "Petra"
    
    #@all_models = Model.all
    # @models_with_reservations = Visit.all.flat_map{|x| x.lines.flat_map(&:model) }.uniq
    # @models_without_reservations = @all_models - @models_with_reservations
  end

  describe "availability" do
    it "all items are available if there are no running reservations" do
      pending
      #@models_without_reservations.all? do |model|
      #  InventoryPool.all.all? do |ip|
      #    aq = model.availability_changes_in(ip).changes.select {|x| x.date >= Date.today and x.date <= Date.today }.flat_map(&:quantities)
      #  end
      #end.should be_true
    end
    
    it "all lines are available" do
      pending
      #Visit.all.flat_map(&:lines).all?(&:available?).should be_true
    end
    
    it "the quantity of items for users" do
      User.all.each do |user|
        Model.all.each do |model|
          user.items.where(:model_id => model).count.should == model.items.where(:inventory_pool_id => user.inventory_pools).count
        end
      end
    end
    
    it "total borrowable items" do
      # NOTE: DONT EXPECT THINGS THAT YOU MIGHT KNOW FROM THE PERSONAS !!!
      # HINT: infact they can change !!!
      # model = Model.find_by_name("Sharp Beamer")
      # model.items.count.should == 3
      # model.total_borrowable_items_for_user(@normin).should == 3
    end
    
    context "scoped by inventory_pool" do
      it "items available" do
        model = Model.find_by_name("Sharp Beamer")
        ip_a = InventoryPool.find_by_name "A-Ausleihe"
        model.total_borrowable_items_for_user(@normin, ip_a).should == 2
        ip_b = InventoryPool.find_by_name "IT-Ausleihe"
        model.total_borrowable_items_for_user(@normin, ip_b).should == 1
      end
      
      it "the maximum quantity available for users" do
        pending
      end
    end

    #context "group partitions, when no partition is defined" do
    #end
    
  end
end