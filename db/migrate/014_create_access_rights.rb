class CreateAccessRights < ActiveRecord::Migration
  def self.up
    create_table :access_rights do |t| # , :id => false ??
      t.belongs_to :role
      t.belongs_to :user
      t.belongs_to :inventory_pool

      t.timestamps
    end

    # TODO optimize indices
    # add_index(:access_rights, :role_id)
    # add_index(:access_rights, :user_id)
    # add_index(:access_rights, :inventory_pool_id)
    add_index(:access_rights, [:role_id, :user_id, :inventory_pool_id], :unique => true) # TODO 20** not working ???

    create_admin

  end

  def self.down
    drop_table :access_rights
  end
  
  def self.create_admin
    user = User.new(  :email => "",
                      :login => "super_user_1")

    user.unique_id = "super_user_1"
    r = Role.find(:first, :conditions => {:name => "admin"})

    user.access_rights << AccessRight.new(:role => r, :inventory_pool => nil)
    user.save
    puts "Administrator für alle Pools ist " + user.login
  end
end
