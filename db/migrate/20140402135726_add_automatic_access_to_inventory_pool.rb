class AddAutomaticAccessToInventoryPool < ActiveRecord::Migration
  def change
    add_column :inventory_pools, :automatic_access, :boolean

    # the ZHdK authentication controller is not giving access rights anymore
    # then we flag ips and the access rights are created in the after_create hook in user model
    if AuthenticationSystem.default_system.first.try(:name) == "ZHDK Authentication"
      zhdk_default_inventory_pools = ["ITZ-Ausleihe", "AV-Ausleihe", "Veranstaltungstechnik"]
      ips = InventoryPool.where(:name => zhdk_default_inventory_pools)
      ips.each do |ip|
        ip.update_attributes automatic_access: true
      end
    end
  end
end
