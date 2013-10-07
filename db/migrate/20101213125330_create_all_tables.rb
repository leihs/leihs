class CreateAllTables < ActiveRecord::Migration

  # So we dropped all previous migrations and restarted from the schema.rb file
  def self.up

    versions = ActiveRecord::Migrator.get_all_versions
    if versions.size > 0

      if versions.include? 20101011133019
        # Nice, we should allready have a correctly working leihs installation.
        # No need for action :-)
        true # no op

      else
        puts <<-EOT.gsub(/^\s+/, '') # unindent
          The database contains migrations, but does not contain the latest
          migration to leihs 2.9.1. Thus I'm assuming that you allready have
          a leihs installation, however that installation is either broken or
          is not at version 2.9.1.
            
          Before installing this version of leihs, please make sure, that you
          are running a correctly installed leihs release 2.9.1 instance
	EOT
        raise "Migration to this leihs release is only possible from a\n" \
              "working 2.9.1 release. Please install leihs version 2.9.1 first."
      end

    else # versions.size == 0

      # This is a fresh install, let's create all leihs tables in the DB
      # The following is adpated from schema.rb from leihs version 2.9.1
      # and replaces all previous migrations.

      create_table :access_rights, :force => true do |t| # , :id => false ??
        t.belongs_to :role
        t.belongs_to :user
        t.belongs_to :inventory_pool
        t.date       :suspended_until
        t.date       :deleted_at
        t.integer    :access_level
        t.timestamps
      end
      change_table :access_rights do |t|
        t.index :suspended_until
        t.index :deleted_at
        t.index [:user_id, :inventory_pool_id], :unique => true
        t.index :inventory_pool_id
        t.index :role_id
      end


      create_table :accessories, :force => true do |t|
        t.belongs_to :model
        t.string     :name
        t.integer    :quantity
      end
      change_table :accessories do |t|
        t.index :model_id
      end


      create_table :accessories_inventory_pools, :id => false, :force => true \
      do |t|
        t.belongs_to :accessory
        t.belongs_to :inventory_pool
      end
      change_table :accessories_inventory_pools do |t|
        t.index [:accessory_id, :inventory_pool_id], :unique => true,
                :name => 'index_accessories_inventory_pools'
        t.index :inventory_pool_id
      end


      create_table :attachments, :force => true do |t|
        t.belongs_to :model
        t.boolean    :is_main,  :default => false

	### attachment_fu
        t.string  :content_type
        t.string  :filename
        t.integer :size
	###
      end
      change_table :attachments do |t|
        t.index :model_id
      end


      create_table :authentication_systems, :force => true do |t|
        t.string  :name
        t.string  :class_name
        t.boolean :is_default, :default => false
        t.boolean :is_active,  :default => false
      end


      create_table :availability_changes, :force => true do |t|
        t.date       :date
        t.belongs_to :inventory_pool
        t.belongs_to :model
        t.timestamps
      end
      change_table :availability_changes do |t|
        t.index [:date, :inventory_pool_id, :model_id], :unique => true,
                :name => "index_on_date_and_inventory_pool_and_model"
        t.index [:inventory_pool_id, :model_id],
                :name => "index_on_inventory_pool_and_model"
      end


      create_table :availability_out_document_lines, :force => true do |t|
        t.belongs_to  :quantity,           :null => false
        t.references  :document_line,      :null => false, :polymorphic => true
      end
      change_table :availability_out_document_lines do |t|
        t.index [:quantity_id, :document_line_type, :document_line_id],
                :unique => true, :name => "index_on_quantity_document_line"
        t.index [:document_line_type, :document_line_id],
                :name => "index_on_document_line"
      end


      create_table :availability_quantities, :force => true do |t|
        t.belongs_to :change
        t.belongs_to :group
        t.integer    :in_quantity,  :default => 0
        t.integer    :out_quantity, :default => 0
      end
      change_table :availability_quantities do |t|
        t.index [:change_id, :group_id], :unique => true
        t.index :in_quantity
      end


      # TODO acts_as_backupable
      create_table :backup_order_lines, :force => true do |t|
        t.belongs_to :model
        t.belongs_to :order
        t.belongs_to :inventory_pool
        t.integer    :quantity
        t.date       :start_date
        t.date       :end_date
        t.timestamps
      end
      change_table :backup_order_lines do |t|
        t.index :order_id
      end


      # TODO acts_as_backupable
      create_table :backup_orders, :force => true do |t|
        t.belongs_to :order          # reference to orginal
        t.belongs_to :user
        t.belongs_to :inventory_pool
        t.integer    :status_const,  :default => 1
        t.string     :purpose
        t.boolean    :delta,         :default => true
        t.timestamps
      end
      change_table :backup_orders do |t|
        t.index :inventory_pool_id
        t.index :order_id
        t.index :status_const
        t.index :user_id
      end


      create_table :buildings, :force => true do |t|
        t.string :name
        t.string :code
      end


      # TODO 13** where is it used ???
      # TODO throw away - it's not used any more
      create_table :comments, :force => true do |t|
        t.string     :title,       :limit => 50
        t.text       :comment
        t.datetime   :created_at
        t.references :commentable, :null => false, :polymorphic => true
        t.belongs_to :user
      end
      change_table :comments do |t|
        t.index [:commentable_id, :commentable_type]
        t.index :user_id
      end


      create_table :contract_lines, :force => true do |t|
        t.belongs_to :contract
        t.string     :type,     :default => 'ItemLine',
                                :null => false # STI (single table inheritance)
        t.belongs_to :item
        t.belongs_to :model
        t.integer    :quantity, :default => 1
        t.date       :start_date
        t.date       :end_date
        t.date       :returned_date
        t.belongs_to :option,   :null => true
        t.timestamps
      end
      change_table :contract_lines do |t|
        t.index :start_date
        t.index :end_date
        t.index :returned_date
        t.index :option_id
        t.index :type
        t.index :contract_id, :name => "fk_contract_lines_contract_id"
        t.index :item_id, :name => "fk_contract_lines_item_id"
        t.index :model_id, :name => "fk_contract_lines_model_id"
      end


      create_table :contracts, :force => true do |t|
        t.belongs_to :user
        t.belongs_to :inventory_pool
        t.integer    :status_const,  :default => 1
        t.text       :purpose
        t.text       :note
        t.boolean    :delta,         :default => true
        t.timestamps
      end
      change_table :contracts do |t|
        t.index :delta
        t.index :inventory_pool_id
        t.index :status_const
        t.index :user_id
      end


      create_table :database_authentications, :force => true do |t|
        t.string     :login
        t.string     :crypted_password, :limit => 40
        t.string     :salt,             :limit => 40
        t.belongs_to :user
        t.timestamps
      end


      create_table :groups, :force => true do |t|
        t.string     :name
        t.belongs_to :inventory_pool
        t.boolean    :delta,         :default => true
        t.timestamps
      end
      change_table :groups do |t|
        t.index :delta
        t.index :inventory_pool_id
      end


      create_table :groups_users, :id => false, :force => true do |t|
        t.belongs_to :user
        t.belongs_to :group
      end
      change_table :groups_users do |t|
        t.index [:user_id, :group_id], :unique => true
        t.index :group_id
      end


      create_table :histories, :force => true do |t|
        t.string     :text,        :default => ""
        t.integer    :type_const
        t.datetime   :created_at,  :null => false
        t.references :target,      :null => false, :polymorphic => true
        t.belongs_to :user
      end
      change_table :histories do |t|
        t.index [:target_type, :target_id]
        t.index :type_const
        t.index :user_id
      end


      create_table :holidays, :force => true do |t|
        t.belongs_to :inventory_pool
        t.date       :start_date
        t.date       :end_date
        t.string     :name
      end
      change_table :holidays do |t|
        t.index :inventory_pool_id
      end


      create_table :images, :force => true do |t|
        t.belongs_to :model
        t.boolean    :is_main,      :default => false

	### attachment_fu
        t.string  :content_type
        t.string  :filename
        t.integer :size
        t.integer :height
        t.integer :width
        t.integer :parent_id
        t.string  :thumbnail
	###
      end
      change_table :images do |t|
        t.index :model_id
      end


      create_table :inventory_pools, :force => true do |t|
        t.string  :name
        t.text    :description
        t.string  :contact_details
        t.string  :contract_description
        t.string  :contract_url
        t.string  :logo_url
        t.text    :default_contract_note, :null => true
        t.string  :shortname
        t.string  :email
        t.text    :color
        t.boolean :print_contracts,       :default => true
        t.boolean :delta,                 :default => true
      end
      change_table :inventory_pools do |t|
        t.index :delta
      end


      create_table :inventory_pools_model_groups, :id => false, :force => true\
      do |t|
        t.belongs_to :inventory_pool
        t.belongs_to :model_group
      end
      change_table :inventory_pools_model_groups do |t|
        t.index :inventory_pool_id
        t.index :model_group_id
      end


      create_table :items, :force => true do |t|
        t.string     :inventory_code
        t.string     :serial_number
        t.belongs_to :model
        t.belongs_to :location
        t.belongs_to :supplier
        t.integer    :owner_id
        t.integer    :parent_id,             :null => true # used for packages
        t.string     :invoice_number
        t.date       :invoice_date
        t.date       :last_check,            :default => nil
        t.date       :retired,               :default => nil
        t.string     :retired_reason,        :default => nil
        t.decimal    :price,                 :precision => 8, :scale => 2
        t.boolean    :is_broken,             :default => false
        t.boolean    :is_incomplete,         :default => false
        t.boolean    :is_borrowable,         :default => false
        t.boolean    :needs_permission,      :default => false
        t.belongs_to :inventory_pool
        t.boolean    :is_inventory_relevant, :default => true
        t.string     :responsible
        t.string     :insurance_number
        t.text       :note
        t.text       :name
        t.boolean    :delta,                 :default => true
        t.timestamps
      end
      change_table :items do |t|
        t.index :delta
        t.index :inventory_pool_id
        t.index :retired
        t.index :inventory_code, :unique => true
        t.index :is_borrowable
        t.index :is_broken
        t.index :is_incomplete
        t.index :location_id
        t.index :model_id
        t.index :owner_id
        t.index :parent_id
      end


      create_table :languages, :force => true do |t|
        t.string  :name
        t.string  :locale_name
        t.boolean :default
        t.boolean :active
      end


      create_table :locations, :force => true do |t|
        t.string     :room
        t.string     :shelf
        t.belongs_to :building
        t.boolean    :delta,   :default => true
      end
      change_table :locations do |t|
        t.index :delta
        t.index :building_id
      end


      create_table :model_groups, :force => true do |t|
        t.string   :type   # STI (single table inheritance)
        t.string   :name
        t.boolean  :delta, :default => true
        t.timestamps
      end
      change_table :model_groups do |t|
        t.index :delta
      end


      create_table :model_groups_parents, :id => false, :force => true do |t|
        t.belongs_to :model_group
        t.belongs_to :parent
        t.string     :label
      end
      change_table :model_groups_parents do |t|
        t.index :model_group_id
        t.index :parent_id
      end


      create_table :model_links, :force => true do |t|
        t.belongs_to :model_group
        t.belongs_to :model
        t.integer    :quantity,   :default => 1
      end
      change_table :model_links do |t|
        t.index :model_group_id
        t.index :model_id
      end


      create_table :models, :force => true do |t|
        t.string   :name,                :null => false
        t.string   :manufacturer
        t.string   :description
        t.string   :internal_description
        t.string   :info_url
        t.decimal  :rental_price,        :precision => 8, :scale => 2
        t.integer  :maintenance_period,  :default => 0
        t.boolean  :is_package,          :default => false
        t.string   :technical_detail
        t.boolean  :delta,               :default => true
        t.timestamps
      end
      change_table :models do |t|
        t.index :delta
        t.index :is_package
      end


      create_table :models_compatibles, :id => false, :force => true do |t|
        t.belongs_to :model
        t.belongs_to :compatible
      end
      change_table :models_compatibles do |t|
        t.index :compatible_id
        t.index :model_id
      end


      create_table :notifications, :force => true do |t|
        t.belongs_to :user
        t.string     :title,      :default => ""
        t.datetime   :created_at, :null => false
      end
      change_table :notifications do |t|
        t.index :user_id
      end


      create_table :numerators, :force => true do |t|
        t.integer :item
      end


      create_table :options, :force => true do |t|
        t.belongs_to :inventory_pool
        t.string   :inventory_code
        t.string   :name
        t.decimal  :price,       :precision => 8, :scale => 2
        t.boolean  :delta,       :default => true
      end
      change_table :options do |t|
        t.index :delta
        t.index :inventory_pool_id
      end


      create_table :order_lines, :force => true do |t|
        t.belongs_to :model
        t.belongs_to :order
        t.belongs_to :inventory_pool
        t.integer    :quantity,      :default => 1
        t.date       :start_date
        t.date       :end_date
        t.timestamps
      end
      change_table :order_lines do |t|
        t.index :start_date
        t.index :end_date
        t.index :inventory_pool_id
        t.index :model_id
        t.index :order_id
      end


      create_table :orders, :force => true do |t|
        t.belongs_to :user
        t.belongs_to :inventory_pool
        t.integer    :status_const,  :default => 1
        t.text       :purpose
        t.boolean    :delta,         :default => true
        t.timestamps
      end
      change_table :orders do |t|
        t.index :delta
        t.index :inventory_pool_id
        t.index :status_const
        t.index :user_id
      end


      create_table :properties, :force => true do |t|
        t.belongs_to :model
        t.string     :key
        t.string     :value
      end
      change_table :properties do |t|
        t.index :model_id
      end


      create_table :roles, :force => true do |t|
        t.integer :parent_id # acts_as_nested_set
        t.integer :lft       # acts_as_nested_set
        t.integer :rgt       # acts_as_nested_set

        t.string  :name
        t.boolean :delta,    :default => true
      end
      change_table :roles do |t|
        t.index :delta
        t.index :parent_id
        t.index :lft
        t.index :rgt
        t.index :name
      end


      create_table :suppliers, :force => true do |t|
        t.string   :name
        t.timestamps
      end


      create_table :users, :force => true do |t|
        t.string     :login
        t.string     :firstname
        t.string     :lastname
        t.string     :phone
        t.belongs_to :authentication_system, :default => 1
        t.string     :unique_id
        t.string     :email
        t.string     :badge_id
        t.string     :address
        t.string     :city
        t.string     :zip
        t.string     :country
        t.integer    :language_id,           :default => 1
        t.text       :extended_info  # serialized
        t.boolean    :delta,                 :default => true
        t.timestamps
      end
      change_table :users do |t|
        t.index :delta
        t.index :authentication_system_id
      end


      create_table :workdays, :force => true do |t|
        t.belongs_to :inventory_pool
        t.boolean    :monday,        :default => true
        t.boolean    :tuesday,       :default => true
        t.boolean    :wednesday,     :default => true
        t.boolean    :thursday,      :default => true
        t.boolean    :friday,        :default => true
        t.boolean    :saturday,      :default => false
        t.boolean    :sunday,        :default => false
      end
      change_table :workdays do |t|
        t.index :inventory_pool_id
      end
    end
  end


  def self.drop_table_and_indices( table, *indices)
    indices.each { |index| remove_index table, index }
    drop_table table
  end

  def self.down
    self.drop_table_and_indices \
                      "access_rights", 
                      "index_access_rights_on_deleted_at",
                      "index_access_rights_on_inventory_pool_id",
                      "index_access_rights_on_role_id",
                      "index_access_rights_on_suspended_until",
                      "index_access_rights_on_user_id_and_inventory_pool_id"

    self.drop_table_and_indices \
                      "accessories",
                      "index_accessories_on_model_id"

    self.drop_table_and_indices \
                      "accessories_inventory_pools",
                      "index_accessories_inventory_pools",
                      "index_accessories_inventory_pools_on_inventory_pool_id"

    self.drop_table_and_indices \
                      "attachments",
                      "index_attachments_on_model_id"

    self.drop_table_and_indices \
                      "authentication_systems"

    self.drop_table_and_indices \
                      "availability_changes",
                      "index_on_date_and_inventory_pool_and_model",
                      "index_on_inventory_pool_and_model"

    self.drop_table_and_indices \
                      "availability_out_document_lines",
                      "index_on_document_line",
                      "index_on_quantity_document_line"

    self.drop_table_and_indices \
                      "availability_quantities",
                      "index_availability_quantities_on_change_id_and_group_id",
                      "index_availability_quantities_on_in_quantity"

    self.drop_table_and_indices \
                      "backup_order_lines",
                      "index_backup_order_lines_on_order_id"

    self.drop_table_and_indices \
                      "backup_orders",
                      "index_backup_orders_on_inventory_pool_id",
                      "index_backup_orders_on_order_id",
                      "index_backup_orders_on_status_const",
                      "index_backup_orders_on_user_id"

    self.drop_table_and_indices \
                      "buildings"

    self.drop_table_and_indices \
                      "comments",
                      "index_comments_on_commentable_type_and_commentable_id",
                      "index_comments_on_user_id"

    self.drop_table_and_indices \
                      "contract_lines",
                      "fk_contract_lines_contract_id",
                      "index_contract_lines_on_end_date",
                      "fk_contract_lines_item_id",
                      "fk_contract_lines_model_id",
                      "index_contract_lines_on_option_id",
                      "index_contract_lines_on_returned_date",
                      "index_contract_lines_on_start_date",
                      "index_contract_lines_on_type"

    self.drop_table_and_indices \
                      "contracts",
                      "index_contracts_on_delta",
                      "index_contracts_on_inventory_pool_id",
                      "index_contracts_on_status_const",
                      "index_contracts_on_user_id"

    self.drop_table_and_indices \
                      "database_authentications"

    self.drop_table_and_indices \
                      "groups",
                      "index_groups_on_delta",
                      "index_groups_on_inventory_pool_id"

    self.drop_table_and_indices \
                      "groups_users",
                      "index_groups_users_on_group_id",
                      "index_groups_users_on_user_id_and_group_id"

    self.drop_table_and_indices \
                      "histories",
                      "index_histories_on_target_type_and_target_id",
                      "index_histories_on_type_const",
                      "index_histories_on_user_id"

    self.drop_table_and_indices \
                      "holidays",
                      "index_holidays_on_inventory_pool_id"

    self.drop_table_and_indices \
                      "images",
                      "index_images_on_model_id"

    self.drop_table_and_indices \
                      "inventory_pools",
                      "index_inventory_pools_on_delta"

    self.drop_table_and_indices \
                      "inventory_pools_model_groups",
                      "index_inventory_pools_model_groups_on_inventory_pool_id",
                      "index_inventory_pools_model_groups_on_model_group_id"

    self.drop_table_and_indices \
                      "items",
                      "index_items_on_delta",
                      "index_items_on_inventory_code",
                      "index_items_on_inventory_pool_id",
                      "index_items_on_is_borrowable",
                      "index_items_on_is_broken",
                      "index_items_on_is_incomplete",
                      "index_items_on_location_id",
                      "index_items_on_model_id",
                      "index_items_on_owner_id",
                      "index_items_on_parent_id",
                      "index_items_on_retired"

    self.drop_table_and_indices \
                      "languages"

    self.drop_table_and_indices \
                      "locations",
                      "index_locations_on_building_id",
                      "index_locations_on_delta"

    self.drop_table_and_indices \
                      "model_groups",
                      "index_model_groups_on_delta"

    self.drop_table_and_indices \
                      "model_groups_parents",
                      "index_model_groups_parents_on_model_group_id",
                      "index_model_groups_parents_on_parent_id"

    self.drop_table_and_indices \
                      "model_links",
                      "index_model_links_on_model_group_id",
                      "index_model_links_on_model_id"

    self.drop_table_and_indices \
                      "models",
                      "index_models_on_delta",
                      "index_models_on_is_package"

    self.drop_table_and_indices \
                      "models_compatibles",
                      "index_models_compatibles_on_compatible_id",
                      "index_models_compatibles_on_model_id"

    self.drop_table_and_indices \
                      "notifications",
                      "index_notifications_on_user_id"

    self.drop_table_and_indices \
                      "numerators"

    self.drop_table_and_indices \
                      "options",
                      "index_options_on_delta",
                      "index_options_on_inventory_pool_id"

    self.drop_table_and_indices \
                      "order_lines",
                      "index_order_lines_on_end_date",
                      "index_order_lines_on_inventory_pool_id",
                      "index_order_lines_on_model_id",
                      "index_order_lines_on_order_id",
                      "index_order_lines_on_start_date"

    self.drop_table_and_indices \
                      "orders",
                      "index_orders_on_delta",
                      "index_orders_on_inventory_pool_id",
                      "index_orders_on_status_const",
                      "index_orders_on_user_id"

    self.drop_table_and_indices \
                      "properties",
                      "index_properties_on_model_id"

    self.drop_table_and_indices \
                      "roles",
                      "index_roles_on_delta",
                      "index_roles_on_lft",
                      "index_roles_on_name",
                      "index_roles_on_parent_id",
                      "index_roles_on_rgt"

    self.drop_table_and_indices \
                      "suppliers"

    self.drop_table_and_indices \
                      "users",
                      "index_users_on_authentication_system_id",
                      "index_users_on_delta"

    self.drop_table_and_indices \
                      "workdays",
                      "index_workdays_on_inventory_pool_id"
  end
end
