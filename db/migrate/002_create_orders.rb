class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :user_id, :null => false
      t.string :status, :default => 'new'
      t.timestamps
    end
    
    #execute "alter table orders add constraint fk_order_user foreign key (user_id) references users(id)"
    
  end

  def self.down
    drop_table :orders
  end
end
