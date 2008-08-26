class Importer
  
  def start(max = 9999999)
    msg = InventoryImport::Importer.new.start(max)
    msg << create_admin
    msg
  end
  
  def create_admin
        
    user = User.create(:unique_id => "super_user",
                       :email => "",
                       :login => "super_user_1")

    r = Role.find(:first, :conditions => {:name => "admin"})
#old#
#    ips = InventoryPool.find(:all)
#    ips.each do |ip|
#      user.access_rights << AccessRight.new(:role => r, :inventory_pool => ip)
#    end
#    user.save

     user.access_rights << AccessRight.new(:role => r, :inventory_pool => nil)

    "Administrator für alle Pools ist " + user.login
  end
  
end