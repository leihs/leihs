# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090106104142) do

  create_table "access_rights", :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.integer  "inventory_pool_id"
    t.integer  "level",             :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_rights", ["user_id", "inventory_pool_id"], :name => "index_access_rights_on_user_id_and_inventory_pool_id", :unique => true
  add_index "access_rights", ["role_id"], :name => "fk_access_rights_role_id"
  add_index "access_rights", ["inventory_pool_id"], :name => "fk_access_rights_inventory_pool_id"

  create_table "accessories", :force => true do |t|
    t.integer "model_id"
    t.string  "name"
    t.integer "quantity"
  end

  add_index "accessories", ["model_id"], :name => "fk_accessories_model_id"

  create_table "accessories_inventory_pools", :id => false, :force => true do |t|
    t.integer "accessory_id"
    t.integer "inventory_pool_id"
  end

  add_index "accessories_inventory_pools", ["accessory_id", "inventory_pool_id"], :name => "index_accessories_inventory_pools", :unique => true
  add_index "accessories_inventory_pools", ["inventory_pool_id"], :name => "fk_accessories_inventory_pools_inventory_pool_id"

  create_table "authentication_systems", :force => true do |t|
    t.string  "name"
    t.string  "class_name"
    t.boolean "is_default", :default => false
    t.boolean "is_active",  :default => false
  end

  create_table "backup_order_lines", :force => true do |t|
    t.integer  "model_id"
    t.integer  "order_id"
    t.integer  "inventory_pool_id"
    t.integer  "quantity"
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "backup_orders", :force => true do |t|
    t.integer  "order_id"
    t.integer  "user_id"
    t.integer  "inventory_pool_id"
    t.integer  "status_const",      :default => 1
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "backup_orders", ["status_const"], :name => "index_backup_orders_on_status_const"
  add_index "backup_orders", ["order_id"], :name => "fk_backup_orders_order_id"
  add_index "backup_orders", ["user_id"], :name => "fk_backup_orders_user_id"
  add_index "backup_orders", ["inventory_pool_id"], :name => "fk_backup_orders_inventory_pool_id"

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50
    t.text     "comment"
    t.datetime "created_at"
    t.integer  "commentable_id",                 :null => false
    t.string   "commentable_type",               :null => false
    t.integer  "user_id"
  end

  add_index "comments", ["user_id"], :name => "fk_comments_user_id"

  create_table "contract_lines", :force => true do |t|
    t.integer  "contract_id"
    t.integer  "item_id"
    t.integer  "model_id"
    t.integer  "location_id"
    t.integer  "quantity",      :default => 1
    t.date     "start_date"
    t.date     "end_date"
    t.date     "returned_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contract_lines", ["contract_id"], :name => "fk_contract_lines_contract_id"
  add_index "contract_lines", ["item_id"], :name => "fk_contract_lines_item_id"
  add_index "contract_lines", ["model_id"], :name => "fk_contract_lines_model_id"
  add_index "contract_lines", ["location_id"], :name => "fk_contract_lines_location_id"

  create_table "contracts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "inventory_pool_id"
    t.integer  "status_const",      :default => 1
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contracts", ["status_const"], :name => "index_contracts_on_status_const"
  add_index "contracts", ["user_id"], :name => "fk_contracts_user_id"
  add_index "contracts", ["inventory_pool_id"], :name => "fk_contracts_inventory_pool_id"

  create_table "histories", :force => true do |t|
    t.string   "text",        :default => ""
    t.integer  "type_const"
    t.datetime "created_at",                  :null => false
    t.integer  "target_id",                   :null => false
    t.string   "target_type",                 :null => false
    t.integer  "user_id"
  end

  add_index "histories", ["user_id"], :name => "fk_histories_user_id"

  create_table "holidays", :force => true do |t|
    t.integer "inventory_pool_id"
    t.date    "start_date"
    t.date    "end_date"
    t.string  "name"
  end

  add_index "holidays", ["inventory_pool_id"], :name => "fk_holidays_inventory_pool_id"

  create_table "images", :force => true do |t|
    t.integer "model_id"
    t.boolean "is_main",      :default => false
    t.string  "content_type"
    t.string  "filename"
    t.integer "size"
    t.integer "height"
    t.integer "width"
    t.integer "parent_id"
    t.string  "thumbnail"
  end

  add_index "images", ["model_id"], :name => "fk_images_model_id"

  create_table "inventory_pools", :force => true do |t|
    t.string "name"
    t.text   "description"
    t.string "contact_details"
    t.string "contract_description"
    t.string "contract_url"
    t.string "logo_url"
  end

  create_table "inventory_pools_model_groups", :id => false, :force => true do |t|
    t.integer "inventory_pool_id"
    t.integer "model_group_id"
  end

  add_index "inventory_pools_model_groups", ["inventory_pool_id"], :name => "fk_inventory_pools_model_groups_inventory_pool_id"
  add_index "inventory_pools_model_groups", ["model_group_id"], :name => "fk_inventory_pools_model_groups_model_group_id"

  create_table "items", :force => true do |t|
    t.string   "inventory_code"
    t.string   "serial_number"
    t.integer  "model_id"
    t.integer  "location_id"
    t.integer  "supplier_id"
    t.integer  "owner_id"
    t.integer  "parent_id"
    t.integer  "required_level",                               :default => 1
    t.string   "invoice_number"
    t.date     "invoice_date"
    t.date     "last_check"
    t.date     "retired"
    t.string   "retired_reason"
    t.decimal  "price",          :precision => 8, :scale => 2
    t.boolean  "is_broken",                                    :default => false
    t.boolean  "is_incomplete",                                :default => false
    t.boolean  "is_borrowable",                                :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["inventory_code"], :name => "index_items_on_inventory_code", :unique => true
  add_index "items", ["required_level"], :name => "index_items_on_required_level"
  add_index "items", ["is_broken"], :name => "index_items_on_is_broken"
  add_index "items", ["is_incomplete"], :name => "index_items_on_is_incomplete"
  add_index "items", ["is_borrowable"], :name => "index_items_on_is_borrowable"
  add_index "items", ["model_id"], :name => "fk_items_model_id"
  add_index "items", ["location_id"], :name => "fk_items_location_id"
  add_index "items", ["owner_id"], :name => "fk_items_owner_id"
  add_index "items", ["parent_id"], :name => "fk_items_parent_id"

  create_table "locations", :force => true do |t|
    t.integer "inventory_pool_id"
    t.boolean "is_main",           :default => false
    t.string  "building"
    t.string  "room"
    t.string  "shelf"
  end

  add_index "locations", ["inventory_pool_id"], :name => "fk_locations_inventory_pool_id"

  create_table "model_groups", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "model_groups_parents", :id => false, :force => true do |t|
    t.integer "model_group_id"
    t.integer "parent_id"
    t.string  "label"
  end

  add_index "model_groups_parents", ["model_group_id"], :name => "fk_model_groups_parents_model_group_id"
  add_index "model_groups_parents", ["parent_id"], :name => "fk_model_groups_parents_parent_id"

  create_table "model_links", :force => true do |t|
    t.integer "model_group_id"
    t.integer "model_id"
    t.integer "quantity",       :default => 1
  end

  add_index "model_links", ["model_group_id"], :name => "fk_model_links_model_group_id"
  add_index "model_links", ["model_id"], :name => "fk_model_links_model_id"

  create_table "models", :force => true do |t|
    t.string   "name",                                                                  :null => false
    t.string   "manufacturer"
    t.string   "description"
    t.string   "internal_description"
    t.string   "info_url"
    t.decimal  "rental_price",         :precision => 8, :scale => 2
    t.integer  "maintenance_period",                                 :default => 0
    t.boolean  "is_package",                                         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "models", ["is_package"], :name => "index_models_on_is_package"

  create_table "models_compatibles", :id => false, :force => true do |t|
    t.integer "model_id"
    t.integer "compatible_id"
  end

  add_index "models_compatibles", ["model_id"], :name => "fk_models_compatibles_model_id"
  add_index "models_compatibles", ["compatible_id"], :name => "fk_models_compatibles_compatible_id"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",      :default => ""
    t.datetime "created_at",                 :null => false
  end

  add_index "notifications", ["user_id"], :name => "fk_notifications_user_id"

  create_table "option_maps", :force => true do |t|
    t.integer "inventory_pool_id"
    t.string  "barcode"
    t.string  "text"
  end

  add_index "option_maps", ["inventory_pool_id"], :name => "fk_option_maps_inventory_pool_id"

  create_table "options", :force => true do |t|
    t.integer "contract_id"
    t.integer "quantity"
    t.string  "barcode"
    t.string  "name"
    t.date    "returned_date"
  end

  add_index "options", ["contract_id"], :name => "fk_options_contract_id"

  create_table "order_lines", :force => true do |t|
    t.integer  "model_id"
    t.integer  "order_id"
    t.integer  "inventory_pool_id"
    t.integer  "quantity",          :default => 1
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "order_lines", ["model_id"], :name => "fk_order_lines_model_id"
  add_index "order_lines", ["order_id"], :name => "fk_order_lines_order_id"
  add_index "order_lines", ["inventory_pool_id"], :name => "fk_order_lines_inventory_pool_id"

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "inventory_pool_id"
    t.integer  "status_const",      :default => 1
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["status_const"], :name => "index_orders_on_status_const"
  add_index "orders", ["user_id"], :name => "fk_orders_user_id"
  add_index "orders", ["inventory_pool_id"], :name => "fk_orders_inventory_pool_id"

  create_table "properties", :force => true do |t|
    t.integer "model_id"
    t.string  "key"
    t.string  "value"
  end

  add_index "properties", ["model_id"], :name => "fk_properties_model_id"

  create_table "roles", :force => true do |t|
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.string  "name"
  end

  create_table "suppliers", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "firstname"
    t.string   "lastname"
    t.string   "phone"
    t.integer  "authentication_system_id", :default => 1
    t.string   "unique_id"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["authentication_system_id"], :name => "fk_users_authentication_system_id"

  create_table "workdays", :force => true do |t|
    t.integer "inventory_pool_id"
    t.boolean "monday",            :default => true
    t.boolean "tuesday",           :default => true
    t.boolean "wednesday",         :default => true
    t.boolean "thursday",          :default => true
    t.boolean "friday",            :default => true
    t.boolean "saturday",          :default => false
    t.boolean "sunday",            :default => false
  end

  add_index "workdays", ["inventory_pool_id"], :name => "fk_workdays_inventory_pool_id"

end
