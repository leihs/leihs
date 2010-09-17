class NewAvailablityModule < ActiveRecord::Migration
  def self.up
    create_table :availability_changes do |t|
      t.date       :date
      t.belongs_to :inventory_pool
      t.belongs_to :model

      t.timestamps
    end

    change_table :availability_changes do |t|
      t.index [:date, :inventory_pool_id, :model_id], :unique => true, :name => "index_on_date_and_inventory_pool_and_model"
      t.index [:inventory_pool_id, :model_id], :name => "index_on_inventory_pool_and_model"
    end

    ######

    create_table :availability_quantities do |t|
      t.belongs_to :change
      t.belongs_to :group
      t.integer    :in_quantity, :default => 0
      t.integer    :out_quantity, :default => 0
    end

    change_table :availability_quantities do |t|
      t.index [:change_id, :group_id], :unique => true
      t.index :in_quantity
    end

    ######

    create_table :availability_out_document_lines do |t|
      t.belongs_to :quantity, :null => false
      t.references :document_line, :null => false, :polymorphic => true
    end

    change_table :availability_out_document_lines do |t|
      t.index [:quantity_id, :document_line_type, :document_line_id], :unique => true, :name => "index_on_quantity_document_line"
      t.index [:document_line_type, :document_line_id], :name => "index_on_document_line"
    end

    ######

    remove_column :contract_lines, :cached_available
    remove_column :order_lines, :cached_available

    ######
    
    Group.suspended_delta do
      InventoryPool.all.each do |ip|
        (2..9).each do |i|
          ar = ip.access_rights.all(:conditions => {:level => i})
          unless ar.empty?
            g = ip.groups.find_or_create_by_name("Level #{i}")
            g.users << ar.collect(&:user).compact
          end
        end
        
        ip.models.each do |m|
          partition = {}
          (2..9).each do |i|
            c = m.items.borrowable.count(:conditions => {:required_level => i})
            unless c.zero?
              g = ip.groups.find_or_create_by_name("Level #{i}")
              partition[g.id] = c
            end
          end
          m.availability_changes.init(ip, partition)
        end
      end
    end
    
    remove_column :access_rights, :level
    remove_column :items, :required_level

    ######

    Availability::Change.recompute_all
    
  end

  def self.down
    add_column :access_rights, :level, :integer, :default => 1
    add_column :items, :required_level, :integer, :default => 1

    add_column :order_lines, :cached_available, :boolean, :null => true, :default => nil
    add_column :contract_lines, :cached_available, :boolean, :null => true, :default => nil

    drop_table :availability_out_document_lines
    drop_table :availability_quantities
    drop_table :availability_changes
  end
end

