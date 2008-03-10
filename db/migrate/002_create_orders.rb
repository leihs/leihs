class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.column :user_id, :int, :null => false
      t.column :status, :string, :default => 'new'
      t.timestamps
    end
    
    execute "alter table orders add constraint fk_order_user foreign key (user_id) references users(id)"
    
  end

  def self.down
    drop_table :orders
  end
end
