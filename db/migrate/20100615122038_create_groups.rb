class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string     :name
      t.belongs_to :inventory_pool

      t.boolean :delta, :default => true

      t.timestamps
    end

    change_table :groups do |t|
      t.index :delta
    end
    
    create_table :groups_users, :id => false do |t|
      t.belongs_to :user
      t.belongs_to :group
    end

    # TODO: implement 'General' default group without putting data into the DB
    #       see commented out section in model/user.rb
    #
    # create a 'General' group for every InventoryPool and make all users with
    # access to the respective InventoryPool members of that's InventoryPools'
    # 'General' group
    InventoryPool.all.each do |inv_pool|
      group = Group.create :name => "General",
	                   :inventory_pool_id => inv_pool.id,
			   :users => inv_pool.users
    end
  end

  def self.down
    drop_table :groups_users
    drop_table :groups
  end
end
