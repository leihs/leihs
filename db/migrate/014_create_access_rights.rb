class CreateAccessRights < ActiveRecord::Migration
  def self.up
    create_table :access_rights do |t| # , :id => false ??
      t.belongs_to :role
      t.belongs_to :user
      t.belongs_to :inventory_pool
      t.integer :level, :default => AccessRight::EVERYBODY
      t.timestamps
    end

    add_index(:access_rights, [:user_id, :inventory_pool_id], :unique => true)

    create_admin
  end

  def self.down
    drop_table :access_rights
  end
  
  def self.create_admin
    user = User.new(  :email => "",
                      :login => "super_user_1")

    user.unique_id = "super_user_1"
    user.save
    r = Role.find(:first, :conditions => {:name => "admin"})
    user.access_rights.create(:role => r, :inventory_pool => nil)
    puts _("The administrator %{a} has been created ") % { :a => user.login }
  end
end
