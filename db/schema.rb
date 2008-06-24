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

ActiveRecord::Schema.define(:version => 20) do

  create_table "access_rights", :force => true do |t|
    t.integer  "role_id",           :limit => 11
    t.integer  "user_id",           :limit => 11
    t.integer  "inventory_pool_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "access_rights", ["role_id"], :name => "index_access_rights_on_role_id"
  add_index "access_rights", ["user_id"], :name => "index_access_rights_on_user_id"
  add_index "access_rights", ["inventory_pool_id"], :name => "index_access_rights_on_inventory_pool_id"

  create_table "accessories", :force => true do |t|
    t.integer  "model_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounts", :force => true do |t|
    t.string   "email"
    t.string   "login"
    t.string   "hashed_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "authentication_systems", :force => true do |t|
    t.string "name"
    t.string "class_name"
  end

  create_table "backup_order_lines", :force => true do |t|
    t.integer  "model_id",   :limit => 11
    t.integer  "order_id",   :limit => 11
    t.integer  "quantity",   :limit => 11
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "backup_orders", :force => true do |t|
    t.integer  "order_id",          :limit => 11
    t.integer  "user_id",           :limit => 11
    t.integer  "inventory_pool_id", :limit => 11
    t.integer  "status_const",      :limit => 11, :default => 1
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories_parents", :id => false, :force => true do |t|
    t.integer "category_id", :limit => 11
    t.integer "parent_id",   :limit => 11
  end

  create_table "comments", :force => true do |t|
    t.string   "title",            :limit => 50
    t.text     "comment"
    t.datetime "created_at"
    t.integer  "commentable_id",   :limit => 11,                 :null => false
    t.string   "commentable_type",               :default => "", :null => false
    t.integer  "user_id",          :limit => 11
  end

  add_index "comments", ["user_id"], :name => "fk_comments_user"

  create_table "contract_lines", :force => true do |t|
    t.integer  "contract_id",   :limit => 11
    t.integer  "item_id",       :limit => 11
    t.integer  "model_id",      :limit => 11
    t.integer  "quantity",      :limit => 11, :default => 1
    t.date     "start_date"
    t.date     "end_date"
    t.date     "returned_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracts", :force => true do |t|
    t.integer  "user_id",           :limit => 11
    t.integer  "inventory_pool_id", :limit => 11
    t.integer  "status_const",      :limit => 11, :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contracts_printouts", :id => false, :force => true do |t|
    t.integer  "contract_id", :limit => 11
    t.integer  "printout_id", :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "histories", :force => true do |t|
    t.string   "text",                      :default => ""
    t.integer  "type_const",  :limit => 11
    t.datetime "created_at",                                :null => false
    t.integer  "target_id",   :limit => 11,                 :null => false
    t.string   "target_type",               :default => "", :null => false
    t.integer  "user_id",     :limit => 11
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
    t.integer  "model_id",          :limit => 11
    t.integer  "inventory_pool_id", :limit => 11
    t.integer  "status",            :limit => 11, :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "items", ["inventory_code"], :name => "index_items_on_inventory_code", :unique => true

  create_table "models", :force => true do |t|
    t.string   "name"
    t.string   "manufacturer"
    t.integer  "maintenance_period", :limit => 11, :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "models_packages", :id => false, :force => true do |t|
    t.integer "model_id",   :limit => 11
    t.integer "package_id", :limit => 11
  end

  add_index "models_packages", ["model_id"], :name => "index_models_packages_on_model_id"
  add_index "models_packages", ["package_id"], :name => "index_models_packages_on_package_id"

  create_table "options", :force => true do |t|
    t.integer  "order_line_id", :limit => 11
    t.integer  "quantity",      :limit => 11
    t.string   "name"
    t.string   "remark"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "order_lines", :force => true do |t|
    t.integer  "model_id",   :limit => 11
    t.integer  "order_id",   :limit => 11
    t.integer  "quantity",   :limit => 11, :default => 1
    t.date     "start_date"
    t.date     "end_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "orders", :force => true do |t|
    t.integer  "user_id",           :limit => 11
    t.integer  "inventory_pool_id", :limit => 11
    t.integer  "status_const",      :limit => 11, :default => 1
    t.string   "purpose"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "packages", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "printouts", :force => true do |t|
    t.binary   "pdf"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties", :force => true do |t|
    t.integer  "model_id",   :limit => 11
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.integer "parent_id", :limit => 11
    t.integer "lft",       :limit => 11
    t.integer "rgt",       :limit => 11
    t.string  "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.integer  "authentication_system_id",  :limit => 11, :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
  end

end
