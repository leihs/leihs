class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.belongs_to :user
      t.integer :status_const, :default => Order::NEW # TODO create index 
      t.string :purpose
      t.timestamps
    end
    
    #execute "alter table orders add constraint fk_order_user foreign key (user_id) references users(id)"
    
  end

  def self.down
    drop_table :orders
  end
end
