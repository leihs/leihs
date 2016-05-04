class CreateAllTables < ActiveRecord::Migration

  # So we dropped all previous migrations and restarted from the schema.rb file
  def self.up

    versions = ActiveRecord::Migrator.get_all_versions
    if versions.size > 0

      last_required_tag = "3.36.0"
      last_required_version = 20151001151820
      last_required_file = File.join Rails.root,
                                     'engines/leihs_admin/app/views/leihs_admin',
                                     'database/not_null_columns.html.haml'

      if versions.include? last_required_version \
        and File.exists? last_required_file
        # Nice, we should allready have a correctly working leihs installation.
        # No need for action :-)
        true # no op

      else
        puts <<-EOT.gsub(/^\s+/, '') # unindent
          The database contains migrations, but does not contain the latest migration to leihs #{last_required_tag}.
          Thus I'm assuming that you already have a leihs installation, however that installation is either broken or
          is not at version #{last_required_tag}.
            
          Before installing this version of leihs, please make sure, that you
          are running a correctly installed leihs release #{last_required_tag} instance
	EOT
        raise "Migration to this leihs release is only possible from a\n" \
              "working #{last_required_tag} release. Please install leihs version #{last_required_tag} first."
      end

    else # versions.size == 0

      # This is a fresh install, let's create all leihs tables in the DB

      create_table :access_rights do |t|
        t.belongs_to :user
        t.belongs_to :inventory_pool
        t.date       :suspended_until
        t.text       :suspended_reason
        t.date       :deleted_at
        t.timestamps null: false
      end
      # create new enum with null allow
      execute "ALTER TABLE access_rights ADD COLUMN role ENUM('#{AccessRight::AVAILABLE_ROLES.join("', '")}')"
      # change enum to null not allowed
      execute "ALTER TABLE access_rights MODIFY role ENUM('#{AccessRight::AVAILABLE_ROLES.join("', '")}') NOT NULL"
      change_table :access_rights do |t|
        t.index :suspended_until
        t.index :deleted_at
        t.index :inventory_pool_id
        t.index :role
        t.index [:user_id, :inventory_pool_id, :deleted_at], :name => :index_on_user_id_and_inventory_pool_id_and_deleted_at
      end


      create_table :accessories do |t|
        t.belongs_to :model
        t.string     :name
        t.integer    :quantity
      end
      change_table :accessories do |t|
        t.index :model_id
      end


      create_table :accessories_inventory_pools, :id => false do |t|
        t.belongs_to :accessory
        t.belongs_to :inventory_pool
      end
      change_table :accessories_inventory_pools do |t|
        t.index [:accessory_id, :inventory_pool_id], :unique => true, :name => 'index_accessories_inventory_pools'
        t.index :inventory_pool_id
      end

      create_table :addresses do |t|
        t.string :street
        t.string :zip_code
        t.string :city
        t.string :country_code
        t.float :latitude
        t.float :longitude
      end
      change_table :addresses do |t|
        t.index [:street, :zip_code, :city, :country_code], :unique => true
      end


      create_table :attachments do |t|
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


      create_table :authentication_systems do |t|
        t.string  :name
        t.string  :class_name
        t.boolean :is_default, :default => false
        t.boolean :is_active,  :default => false
      end


      create_table :buildings do |t|
        t.string :name
        t.string :code
      end


      create_table :reservations do |t|
        t.belongs_to :contract
        t.belongs_to :inventory_pool
        t.belongs_to :user
        t.belongs_to :delegated_user
        t.belongs_to :handed_over_by_user
        t.string     :type,     :default => 'ItemLine', :null => false # STI (single table inheritance)
        t.belongs_to :item
        t.belongs_to :model
        t.integer    :quantity, :default => 1
        t.date       :start_date
        t.date       :end_date
        t.date       :returned_date
        t.belongs_to :option,   :null => true
        t.belongs_to :purpose
        t.belongs_to :returned_to_user
        t.timestamps null: false
      end
      execute "ALTER TABLE reservations ADD COLUMN status ENUM('#{Reservation::STATUSES.join("', '")}') NOT NULL;"
      change_table :reservations do |t|
        t.index :start_date
        t.index :end_date
        t.index :option_id
        t.index :contract_id
        t.index :item_id
        t.index :model_id
        t.index [:returned_date, :contract_id]
        t.index [:type, :contract_id]
        t.index :status
      end

      create_table :contracts do |t|
        t.text       :note
        t.timestamps null: false
      end

      create_table :database_authentications do |t|
        t.string     :login
        t.string     :crypted_password, :limit => 40
        t.string     :salt,             :limit => 40
        t.belongs_to :user
        t.timestamps null: false
      end


      create_table :delegations_users, :id => false do |t|
        t.belongs_to :delegation
        t.belongs_to :user
      end
      change_table :delegations_users do |t|
        t.index [:user_id, :delegation_id], :unique => true
        t.index :delegation_id
      end

      create_table :groups do |t|
        t.string     :name
        t.belongs_to :inventory_pool
        t.boolean    :is_verification_required, default: false
        t.timestamps null: false
      end
      change_table :groups do |t|
        t.index :inventory_pool_id
        t.index   :is_verification_required
      end


      create_table :groups_users, :id => false do |t|
        t.belongs_to :user
        t.belongs_to :group
      end
      change_table :groups_users do |t|
        t.index [:user_id, :group_id], :unique => true
        t.index :group_id
      end

      create_table :holidays do |t|
        t.belongs_to :inventory_pool
        t.date       :start_date
        t.date       :end_date
        t.string     :name
      end
      change_table :holidays do |t|
        t.index :inventory_pool_id
        t.index [:start_date, :end_date]
      end


      create_table :images do |t|
        t.belongs_to :target,       :polymorphic => true
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
        t.index [:target_id, :target_type]
      end


      create_table :inventory_pools do |t|
        t.string     :name
        t.text       :description
        t.string     :contact_details
        t.string     :contract_description
        t.string     :contract_url
        t.string     :logo_url
        t.text       :default_contract_note, :null => true
        t.string     :shortname
        t.string     :email
        t.text       :color
        t.boolean    :print_contracts,       :default => true
        t.text       :opening_hours
        t.belongs_to :address
        t.boolean    :automatic_suspension, null: false, default: false
        t.text       :automatic_suspension_reason
        t.boolean    :automatic_access
        t.boolean    :required_purpose, default: true
      end
      change_table :inventory_pools do |t|
        t.index :name, :unique => true
      end


      create_table :inventory_pools_model_groups, :id => false do |t|
        t.belongs_to :inventory_pool
        t.belongs_to :model_group
      end
      change_table :inventory_pools_model_groups do |t|
        t.index :inventory_pool_id
        t.index :model_group_id
      end


      create_table :items do |t|
        t.string     :inventory_code
        t.string     :serial_number
        t.belongs_to :model
        t.belongs_to :location
        t.belongs_to :supplier
        t.integer    :owner_id,              :null => false
        t.integer    :inventory_pool_id,     :null => false
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
        t.text       :status_note
        t.boolean    :needs_permission,      :default => false
        t.boolean    :is_inventory_relevant, :default => false # per Ramon the default should be "not inventory relevant" by default
        t.string     :responsible
        t.string     :insurance_number
        t.text       :note
        t.text       :name
        t.string     :user_name
        t.text       :properties
        t.timestamps null: false
      end
      change_table :items do |t|
        t.index :inventory_pool_id
        t.index :retired
        t.index :inventory_code, :unique => true
        t.index :is_borrowable
        t.index :is_broken
        t.index :is_incomplete
        t.index :location_id
        t.index :owner_id
        t.index [:parent_id, :retired]
        t.index [:model_id, :retired, :inventory_pool_id]
      end


      create_table :languages do |t|
        t.string  :name
        t.string  :locale_name
        t.boolean :default
        t.boolean :active
      end
      change_table :languages do |t|
        t.index :name, :unique => true
        t.index [:active, :default]
      end


      create_table :locations do |t|
        t.string     :room
        t.string     :shelf
        t.belongs_to :building
      end
      change_table :locations do |t|
        t.index :building_id
      end

      create_table :mail_templates do |t|
        t.belongs_to :inventory_pool, null: true # NOTE when null, then is system-wide
        t.belongs_to :language
        t.string :name
        t.string :format
        t.text :body
      end

      # acts_as_dag
      create_table :model_group_links do |t|
        t.integer :ancestor_id
        t.integer :descendant_id
        t.boolean :direct
        t.integer :count
        t.string  :label
      end
      change_table    :model_group_links do |t|
        t.index       :ancestor_id
        t.index       :direct
        t.index       [:descendant_id, :ancestor_id, :direct], :name => :index_on_descendant_id_and_ancestor_id_and_direct
      end

      create_table :model_groups do |t|
        t.string   :type   # STI (single table inheritance)
        t.string   :name
        t.timestamps null: false
      end
      change_table :model_groups do |t|
        t.index :type
      end


      create_table :model_links do |t|
        t.belongs_to :model_group
        t.belongs_to :model
        t.integer    :quantity,   :default => 1
      end
      change_table :model_links do |t|
        t.index [:model_id, :model_group_id]
        t.index [:model_group_id, :model_id]
      end


      create_table :models do |t|
        t.string   :type,                :default => 'Model', :null => false # STI (single table inheritance)
        t.string   :manufacturer
        t.string   :product,             :null => false
        t.string   :version
        t.string   :description
        t.string   :internal_description
        t.string   :info_url
        t.decimal  :rental_price,        :precision => 8, :scale => 2
        t.integer  :maintenance_period,  :default => 0
        t.boolean  :is_package,          :default => false
        t.string   :technical_detail
        t.text     :hand_over_note
        t.text     :description
        t.text     :internal_description
        t.text     :technical_detail
        t.timestamps null: false
      end
      change_table :models do |t|
        t.index :type
        t.index :is_package
      end


      create_table :models_compatibles, :id => false do |t|
        t.belongs_to :model
        t.belongs_to :compatible
      end
      change_table :models_compatibles do |t|
        t.index :compatible_id
        t.index :model_id
      end


      create_table :notifications do |t|
        t.belongs_to :user
        t.string     :title,      :default => ""
        t.datetime   :created_at, :null => false
      end
      change_table :notifications do |t|
        t.index :user_id
        t.index [:created_at, :user_id]
      end


      create_table :numerators do |t|
        t.integer :item
      end


      create_table :options do |t|
        t.belongs_to :inventory_pool
        t.string     :inventory_code
        t.string     :manufacturer
        t.string     :product,        :null => false
        t.string     :version
        t.decimal    :price,          :precision => 8, :scale => 2
      end
      change_table :options do |t|
        t.index :inventory_pool_id
      end

      create_table :partitions do |t|
        t.belongs_to :model
        t.belongs_to :inventory_pool
        t.belongs_to :group, :null => true
        t.integer :quantity
      end
      change_table :partitions do |t|
        t.index [:model_id, :inventory_pool_id, :group_id], :unique => true
      end

      create_table :properties do |t|
        t.belongs_to :model
        t.string     :key
        t.string     :value
      end
      change_table :properties do |t|
        t.index :model_id
      end

      create_table :purposes do |t|
        t.text :description
      end


      create_table :settings do |t|
        t.string  :smtp_address
        t.integer :smtp_port
        t.string  :smtp_domain
        t.string  :local_currency_string
        t.text    :contract_terms
        t.text    :contract_lending_party_string
        t.string  :email_signature
        t.string  :default_email
        t.boolean :deliver_order_notifications
        t.string  :user_image_url
        t.string  :ldap_config
        t.string  :logo_url
        t.string  :mail_delivery_method
        t.string  :smtp_username
        t.string  :smtp_password
        t.boolean :smtp_enable_starttls_auto, null: false, default: false
        t.string  :smtp_openssl_verify_mode, null: false, default: 'none'
        t.string  :time_zone, null: false, default: 'Bern'
        t.boolean :disable_manage_section, null: false, default: false
        t.text    :disable_manage_section_message
        t.boolean :disable_borrow_section, null: false, default: false
        t.text    :disable_borrow_section_message, :text
        t.integer :timeout_minutes, default: 30, null: false
      end


      create_table :suppliers do |t|
        t.string   :name, :null => false
        t.timestamps null: false
      end
      change_table :suppliers do |t|
        t.index   :name, :unique => true
      end

      create_table :users do |t|
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
        t.integer    :language_id,           :default => nil
        t.text       :extended_info  # serialized
        t.string     :settings, :limit => 1024
        t.belongs_to :delegator_user
        t.timestamps null: false
      end
      change_table :users do |t|
        t.index :authentication_system_id
      end

      create_table :workdays do |t|
        t.belongs_to :inventory_pool
        t.boolean    :monday,        :default => true
        t.boolean    :tuesday,       :default => true
        t.boolean    :wednesday,     :default => true
        t.boolean    :thursday,      :default => true
        t.boolean    :friday,        :default => true
        t.boolean    :saturday,      :default => false
        t.boolean    :sunday,        :default => false
        t.integer    :reservation_advance_days,  :default => 0, :null => true
        t.text       :max_visits # serialized
      end
      change_table :workdays do |t|
        t.index :inventory_pool_id
      end

      ############### SQL Views ###############

      execute("CREATE VIEW partitions_with_generals AS " \
                "SELECT model_id, inventory_pool_id, group_id, quantity " \
                "FROM partitions " \
              "UNION " \
                "SELECT model_id, inventory_pool_id, NULL as group_id, " \
                  "(COUNT(i.id) - IFNULL((SELECT SUM(quantity) FROM partitions AS p " \
                      "WHERE p.model_id = i.model_id AND p.inventory_pool_id = i.inventory_pool_id " \
                      "GROUP BY p.inventory_pool_id, p.model_id), 0)) as quantity " \
                "FROM items AS i WHERE i.retired IS NULL AND i.is_borrowable = 1 AND i.parent_id IS NULL " \
                "GROUP BY i.inventory_pool_id, i.model_id;")


      begin
        add_foreign_key(:access_rights, :inventory_pools, on_delete: :cascade)
        add_foreign_key(:access_rights, :users)
        add_foreign_key(:accessories, :models, on_delete: :cascade)
        add_foreign_key(:attachments, :models, on_delete: :cascade)
        add_foreign_key(:database_authentications, :users, on_delete: :cascade)
        add_foreign_key(:groups, :inventory_pools)
        add_foreign_key(:holidays, :inventory_pools, on_delete: :cascade)
        add_foreign_key(:inventory_pools, :addresses)
        add_foreign_key(:items, :inventory_pools)
        add_foreign_key(:items, :inventory_pools, column: 'owner_id')
        add_foreign_key(:items, :items, column: 'parent_id', on_delete: :nullify)
        add_foreign_key(:items, :locations)
        add_foreign_key(:items, :models)
        add_foreign_key(:items, :suppliers)
        add_foreign_key(:locations, :buildings)
        add_foreign_key(:model_group_links, :model_groups, column: 'ancestor_id', on_delete: :cascade)
        add_foreign_key(:model_group_links, :model_groups, column: 'descendant_id', on_delete: :cascade)
        add_foreign_key(:model_links, :model_groups, on_delete: :cascade)
        add_foreign_key(:model_links, :models, on_delete: :cascade)
        add_foreign_key(:notifications, :users, on_delete: :cascade)
        add_foreign_key(:options, :inventory_pools)
        add_foreign_key(:partitions, :groups)
        add_foreign_key(:partitions, :inventory_pools)
        add_foreign_key(:partitions, :models, on_delete: :cascade)
        add_foreign_key(:properties, :models, on_delete: :cascade)
        add_foreign_key(:reservations, :inventory_pools)
        add_foreign_key(:reservations, :users)
        add_foreign_key(:reservations, :users, column: 'delegated_user_id')
        add_foreign_key(:reservations, :users, column: 'handed_over_by_user_id')
        add_foreign_key(:reservations, :items)
        add_foreign_key(:reservations, :models)
        add_foreign_key(:reservations, :options)
        add_foreign_key(:reservations, :purposes)
        add_foreign_key(:reservations, :contracts, on_delete: :cascade)
        add_foreign_key(:reservations, :users, column: 'returned_to_user_id')
        add_foreign_key(:users, :authentication_systems)
        add_foreign_key(:users, :languages)
        add_foreign_key(:users, :users, column: 'delegator_user_id')
        add_foreign_key(:workdays, :inventory_pools, on_delete: :cascade)

        # join tables
        add_foreign_key(:accessories_inventory_pools, :accessories)
        add_foreign_key(:accessories_inventory_pools, :inventory_pools)
        add_foreign_key(:delegations_users, :users)
        add_foreign_key(:delegations_users, :users, column: 'delegation_id')
        add_foreign_key(:groups_users, :groups)
        add_foreign_key(:groups_users, :users)
        add_foreign_key(:inventory_pools_model_groups, :inventory_pools)
        add_foreign_key(:inventory_pools_model_groups, :model_groups)
        add_foreign_key(:models_compatibles, :models)
        add_foreign_key(:models_compatibles, :models, column: 'compatible_id')

      rescue
        puts %Q(
        *************************************************************************************
        Error: the database has inconsistency issues caused by dead references.
        Please visit the consistency report at the following url: /admin/database/consistency
        After solving the issues, run again: rake db:migrate
        *************************************************************************************
      )

        raise
      end

      ############################################################

      execute %Q(CREATE VIEW visits AS
                SELECT HEX( CONCAT_WS( '_', if((status = '#{:signed}'), end_date, start_date), inventory_pool_id, user_id, status)) as id,
                       inventory_pool_id,
                       user_id,
                       status,
                       IF((status = '#{:signed}'), end_date, start_date) AS date,
                       SUM(quantity) AS quantity
                FROM reservations
                WHERE status IN ('#{:submitted}', '#{:approved}','#{:signed}')
                GROUP BY user_id, status, date, inventory_pool_id
                ORDER BY date;)

      ############################################################

      create_table :audits, :force => true do |t|
        t.column :auditable_id, :integer
        t.column :auditable_type, :string
        t.column :associated_id, :integer
        t.column :associated_type, :string
        t.column :user_id, :integer
        t.column :user_type, :string
        t.column :username, :string
        t.column :action, :string
        t.column :audited_changes, :text
        t.column :version, :integer, :default => 0
        t.column :comment, :string
        t.column :remote_address, :string
        t.column :request_uuid, :string
        t.column :created_at, :datetime
      end
      add_index :audits, [:auditable_id, :auditable_type], :name => 'auditable_index'
      add_index :audits, [:associated_id, :associated_type], :name => 'associated_index'
      add_index :audits, [:user_id, :user_type], :name => 'user_index'
      add_index :audits, :request_uuid
      add_index :audits, :created_at

      create_table :hidden_fields do |t|
        t.string :field_id
        t.belongs_to :user
      end

      create_table :fields, id: false do |t|
        t.primary_key :id, :string, limit: 50
        t.text :data # serialized
        t.boolean :active, default: true
        t.integer :position
      end
      execute 'ALTER TABLE fields ADD PRIMARY KEY (id)'
      change_table :fields do |t|
        t.index :active
      end

    end
  end

end
