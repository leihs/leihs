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

ActiveRecord::Schema.define(:version => 20081007122945) do

  create_table "access_rights", :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.integer  "inventory_pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_rights", ["role_id", "user_id", "inventory_pool_id"], :name => "index_access_rights_on_role_id_and_user_id_and_inventory_pool_id", :unique => true

  create_table "accessories", :force => true do |t|
    t.integer "model_id"
    t.string  "name"
  end

  create_table "accessories_inventory_pools", :id => false, :force => true do |t|
    t.integer "accessory_id"
    t.integer "inventory_pool_id"
  end

  add_index "accessories_inventory_pools", ["accessory_id", "inventory_pool_id"], :name => "index_accessories_inventory_pools", :unique => true

  create_table "authentication_systems", :force => true do |t|
    t.string  "name"
    t.string  "class_name"
    t.boolean "default"
    t.boolean "active"
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

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50
    t.text     "comment"
    t.datetime "created_at"
    t.integer  "commentable_id",                                 :null => false
    t.string   "commentable_type",               :default => "", :null => false
    t.integer  "user_id"
  end

  add_index "comments", ["user_id"], :name => "fk_comments_user"

  create_table "contract_lines", :force => true do |t|
    t.integer  "contract_id"
    t.integer  "item_id"
    t.integer  "model_id"
    t.integer  "quantity",      :default => 1
    t.date     "start_date"
    t.date     "end_date"
    t.date     "returned_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "inventory_pool_id"
    t.integer  "status_const",      :default => 1
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histories", :force => true do |t|
    t.string   "text",        :default => ""
    t.integer  "type_const"
    t.datetime "created_at",                  :null => false
    t.integer  "target_id",                   :null => false
    t.string   "target_type", :default => "", :null => false
    t.integer  "user_id"
  end

  create_table "holidays", :force => true do |t|
    t.integer  "inventory_pool_id"
    t.date     "start_date"
    t.date     "end_date"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer  "model_id"
    t.string   "content_type"
    t.string   "filename"
    t.integer  "size"
    t.integer  "height"
    t.integer  "width"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "inventory_pools", :force => true do |t|
    t.string "name"
    t.text   "description"
    t.string "contract_description"
    t.string "contract_url"
    t.string "logo_url"
  end

  create_table "items", :force => true do |t|
    t.string   "inventory_code"
    t.string   "serial_number"
    t.integer  "model_id"
    t.integer  "location_id"
    t.integer  "status_const",   :default => 1
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["inventory_code"], :name => "index_items_on_inventory_code", :unique => true

  create_table "locations", :force => true do |t|
    t.integer  "inventory_pool_id"
    t.boolean  "main"
    t.string   "building"
    t.string   "room"
    t.string   "shelf"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  add_index "model_groups_parents", ["model_group_id"], :name => "index_model_groups_parents_on_model_group_id"
  add_index "model_groups_parents", ["parent_id"], :name => "index_model_groups_parents_on_parent_id"

  create_table "model_links", :force => true do |t|
    t.integer "model_group_id"
    t.integer "model_id"
    t.integer "quantity"
  end

  add_index "model_links", ["model_group_id"], :name => "index_model_links_on_model_group_id"
  add_index "model_links", ["model_id"], :name => "index_model_links_on_model_id"

  create_table "models", :force => true do |t|
    t.string   "name",               :default => "", :null => false
    t.string   "manufacturer"
    t.integer  "maintenance_period", :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "models_compatibles", :id => false, :force => true do |t|
    t.integer "model_id"
    t.integer "compatible_id"
  end

  add_index "models_compatibles", ["model_id"], :name => "index_models_compatibles_on_model_id"
  add_index "models_compatibles", ["compatible_id"], :name => "index_models_compatibles_on_compatible_id"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",      :default => ""
    t.datetime "created_at",                 :null => false
  end

  create_table "option_maps", :force => true do |t|
    t.string "barcode"
    t.string "text"
  end

  create_table "options", :force => true do |t|
    t.integer  "contract_id"
    t.integer  "quantity"
    t.string   "barcode"
    t.string   "name"
    t.date     "returned_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "orders", :force => true do |t|
    t.integer  "user_id"
    t.integer  "inventory_pool_id"
    t.integer  "status_const",      :default => 1
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties", :force => true do |t|
    t.integer  "model_id"
    t.string   "key"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.string  "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.integer  "authentication_system_id", :default => 1
    t.string   "unique_id"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workdays", :force => true do |t|
    t.integer  "inventory_pool_id"
    t.boolean  "monday",            :default => true
    t.boolean  "tuesday",           :default => true
    t.boolean  "wednesday",         :default => true
    t.boolean  "thursday",          :default => true
    t.boolean  "friday",            :default => true
    t.boolean  "saturday",          :default => false
    t.boolean  "sunday",            :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
