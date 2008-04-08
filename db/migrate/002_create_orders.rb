class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.belongs_to :user
      t.string :status, :default => 'new'
      t.string :purpose
      t.timestamps
    end
    
    #execute "alter table orders add constraint fk_order_user foreign key (user_id) references users(id)"
    
  end

  def self.down
    drop_table :orders
  end
end
