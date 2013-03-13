require 'spec/spec_helper.rb'

require RAILS_ROOT + '/lib/factory.rb'


describe "CSV import for HSLU" do
  before(:all) do
    Factory.create_default_languages
  end

  it "should import the 10 example items correctly and completely" do
    require 'other/csv_import_of_items_for_hslu'
    run_import_with_broken_csv(RAILS_ROOT + "/spec/data/hslu_item_examples.csv")

    # Verify model and item counts
    Model.count.should == 8
    Model.all.collect(&:name).sort.should == ["A - 109", "DSR - PD 570 WSP", "HDR - FX1E",
                                              "HDR - Z1E", "HDR-HC9E", "PMW-EX3", "Video 10",
                                              "iMac  20“/2"]
    Item.count.should == 10

    # Check that the inventory pools mentioned in the CSV file are actually created
    # The following pools should (at the very least) have been created now
    filtered_pools = InventoryPool.all.collect(&:name) & ["Design & Kunst", "Gerätepool", "IT", 
                                                          "Video", "Videowerkstatt", "Videowerkstatt Baselstrasse", 
                                                          "Videowerkstatt Sentimatt"]
    filtered_pools.include?("Design & Kunst").should == true
    filtered_pools.include?("IT").should == true
    filtered_pools.include?("Gerätepool").should == true
    filtered_pools.include?("Video").should == true
    filtered_pools.include?("Videowerkstatt").should == true
    filtered_pools.include?("Videowerkstatt Baselstrasse").should == true
    filtered_pools.include?("Videowerkstatt Sentimatt").should == true

    # Check how a typical borrowable item was imported
    borrowable_item = Item.find(:first, :conditions => {:inventory_code => "1043"})
    borrowable_item.inventory_code.should == "1043"
    borrowable_item.inventory_pool.should == InventoryPool.find_by_name("Videowerkstatt Baselstrasse")
    borrowable_item.owner.should == InventoryPool.find_by_name("Video")
    borrowable_item.serial_number.should == "46620"
    borrowable_item.model.name.should == "DSR - PD 570 WSP"
    borrowable_item.model.categories.first.name.should == "Kamera"
    borrowable_item.supplier.name.should == "Bild +Ton" 
    borrowable_item.model.manufacturer.should == "Sony" 
    borrowable_item.model.description.should == "Kamera DVCam" 
    borrowable_item.invoice_date.should == Date.parse("01.01.2004")
    borrowable_item.is_borrowable?.should == true
    borrowable_item.location.building.name.should == "Baselstrasse 61a"
    borrowable_item.location.room.should == "Videowerkstatt"
    borrowable_item.location.shelf.should == "Schrank 01"
    borrowable_item.last_check.should == Date.parse("13.03.2013")

    # Check how a typical non-borrowable item was imported
    nonborrowable_item = Item.find(:first, :conditions => {:inventory_code => "20037"})
    nonborrowable_item.is_borrowable?.should == false
  end

end
