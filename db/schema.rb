# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 90000000000014) do

  create_table "access_rights", :force => true do |t|
    t.integer  "role_id"
    t.integer  "user_id"
    t.integer  "inventory_pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "suspended_until"
    t.date     "deleted_at"
    t.integer  "access_level"
    t.text     "suspended_reason"
  end

  add_index "access_rights", ["deleted_at"], :name => "index_access_rights_on_deleted_at"
  add_index "access_rights", ["inventory_pool_id"], :name => "index_access_rights_on_inventory_pool_id"
  add_index "access_rights", ["role_id"], :name => "index_access_rights_on_role_id"
  add_index "access_rights", ["suspended_until"], :name => "index_access_rights_on_suspended_until"
  add_index "access_rights", ["user_id", "inventory_pool_id", "deleted_at"], :name => "index_on_user_id_and_inventory_pool_id_and_deleted_at"

  create_table "accessories", :force => true do |t|
    t.integer "model_id"
    t.string  "name"
    t.integer "quantity"
  end

  add_index "accessories", ["model_id"], :name => "index_accessories_on_model_id"

  create_table "accessories_inventory_pools", :id => false, :force => true do |t|
    t.integer "accessory_id"
    t.integer "inventory_pool_id"
  end

  add_index "accessories_inventory_pools", ["accessory_id", "inventory_pool_id"], :name => "index_accessories_inventory_pools", :unique => true
  add_index "accessories_inventory_pools", ["inventory_pool_id"], :name => "index_accessories_inventory_pools_on_inventory_pool_id"

  create_table "addresses", :force => true do |t|
    t.string "street"
    t.string "zip_code"
    t.string "city"
    t.string "country_code"
    t.float  "latitude"
    t.float  "longitude"
  end

  add_index "addresses", ["street", "zip_code", "city", "country_code"], :name => "index_addresses_on_street_and_zip_code_and_city_and_country_code", :unique => true

  create_table "attachments", :force => true do |t|
    t.integer "model_id"
    t.boolean "is_main",      :default => false
    t.string  "content_type"
    t.string  "filename"
    t.integer "size"
  end

  add_index "attachments", ["model_id"], :name => "index_attachments_on_model_id"

  create_table "audits", :force => true do |t|
    t.integer  "thread_id",       :limit => 8
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",                      :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["thread_id"], :name => "index_audits_on_thread_id"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "authentication_systems", :force => true do |t|
    t.string  "name"
    t.string  "class_name"
    t.boolean "is_default", :default => false
    t.boolean "is_active",  :default => false
  end

  create_table "buildings", :force => true do |t|
    t.string "name"
    t.string "code"
  end

  create_table "contract_lines", :force => true do |t|
    t.integer  "contract_id"
    t.integer  "item_id"
    t.integer  "model_id"
    t.integer  "quantity",            :default => 1
    t.date     "start_date"
    t.date     "end_date"
    t.date     "returned_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "option_id"
    t.string   "type",                :default => "ItemLine", :null => false
    t.integer  "purpose_id"
    t.integer  "returned_to_user_id"
  end

  add_index "contract_lines", ["contract_id"], :name => "index_contract_lines_on_contract_id"
  add_index "contract_lines", ["end_date"], :name => "index_contract_lines_on_end_date"
  add_index "contract_lines", ["item_id"], :name => "index_contract_lines_on_item_id"
  add_index "contract_lines", ["model_id"], :name => "index_contract_lines_on_model_id"
  add_index "contract_lines", ["option_id"], :name => "index_contract_lines_on_option_id"
  add_index "contract_lines", ["returned_date", "contract_id"], :name => "index_contract_lines_on_returned_date_and_contract_id"
  add_index "contract_lines", ["start_date"], :name => "index_contract_lines_on_start_date"
  add_index "contract_lines", ["type", "contract_id"], :name => "index_contract_lines_on_type_and_contract_id"

  create_table "contracts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "inventory_pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "note"
    t.integer  "handed_over_by_user_id"
    t.string   "status",                 :limit => 11
  end

  add_index "contracts", ["inventory_pool_id"], :name => "index_contracts_on_inventory_pool_id"
  add_index "contracts", ["status"], :name => "index_contracts_on_status"
  add_index "contracts", ["user_id"], :name => "index_contracts_on_user_id"

  create_table "database_authentications", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password", :limit => 40
    t.string   "salt",             :limit => 40
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.integer  "inventory_pool_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups", ["inventory_pool_id"], :name => "index_groups_on_inventory_pool_id"

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "group_id"
  end

  add_index "groups_users", ["group_id"], :name => "index_groups_users_on_group_id"
  add_index "groups_users", ["user_id", "group_id"], :name => "index_groups_users_on_user_id_and_group_id", :unique => true

  create_table "histories", :force => true do |t|
    t.string   "text",        :default => ""
    t.integer  "type_const"
    t.datetime "created_at",                  :null => false
    t.integer  "target_id",                   :null => false
    t.string   "target_type",                 :null => false
    t.integer  "user_id"
  end

  add_index "histories", ["target_type", "target_id"], :name => "index_histories_on_target_type_and_target_id"
  add_index "histories", ["type_const"], :name => "index_histories_on_type_const"
  add_index "histories", ["user_id"], :name => "index_histories_on_user_id"

  create_table "holidays", :force => true do |t|
    t.integer "inventory_pool_id"
    t.date    "start_date"
    t.date    "end_date"
    t.string  "name"
  end

  add_index "holidays", ["inventory_pool_id"], :name => "index_holidays_on_inventory_pool_id"
  add_index "holidays", ["start_date", "end_date"], :name => "index_holidays_on_start_date_and_end_date"

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

  add_index "images", ["model_id"], :name => "index_images_on_model_id"

  create_table "inventory_pools", :force => true do |t|
    t.string  "name"
    t.text    "description"
    t.string  "contact_details"
    t.string  "contract_description"
    t.string  "contract_url"
    t.string  "logo_url"
    t.text    "default_contract_note"
    t.string  "shortname"
    t.string  "email"
    t.text    "color"
    t.boolean "print_contracts",       :default => true
    t.text    "opening_hours"
    t.integer "address_id"
  end

  add_index "inventory_pools", ["name"], :name => "index_inventory_pools_on_name", :unique => true

  create_table "inventory_pools_model_groups", :id => false, :force => true do |t|
    t.integer "inventory_pool_id"
    t.integer "model_group_id"
  end

  add_index "inventory_pools_model_groups", ["inventory_pool_id"], :name => "index_inventory_pools_model_groups_on_inventory_pool_id"
  add_index "inventory_pools_model_groups", ["model_group_id"], :name => "index_inventory_pools_model_groups_on_model_group_id"

  create_table "items", :force => true do |t|
    t.string   "inventory_code"
    t.string   "serial_number"
    t.integer  "model_id"
    t.integer  "location_id"
    t.integer  "supplier_id"
    t.integer  "owner_id"
    t.integer  "parent_id"
    t.string   "invoice_number"
    t.date     "invoice_date"
    t.date     "last_check"
    t.date     "retired"
    t.string   "retired_reason"
    t.decimal  "price",                                 :precision => 8, :scale => 2
    t.boolean  "is_broken",                                                           :default => false
    t.boolean  "is_incomplete",                                                       :default => false
    t.boolean  "is_borrowable",                                                       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "needs_permission",                                                    :default => false
    t.integer  "inventory_pool_id"
    t.boolean  "is_inventory_relevant",                                               :default => false
    t.string   "responsible"
    t.string   "insurance_number"
    t.text     "note"
    t.text     "name"
    t.string   "user_name"
    t.string   "properties",            :limit => 2048
  end

  add_index "items", ["inventory_code"], :name => "index_items_on_inventory_code", :unique => true
  add_index "items", ["inventory_pool_id"], :name => "index_items_on_inventory_pool_id"
  add_index "items", ["is_borrowable"], :name => "index_items_on_is_borrowable"
  add_index "items", ["is_broken"], :name => "index_items_on_is_broken"
  add_index "items", ["is_incomplete"], :name => "index_items_on_is_incomplete"
  add_index "items", ["location_id"], :name => "index_items_on_location_id"
  add_index "items", ["model_id", "retired", "inventory_pool_id"], :name => "index_items_on_model_id_and_retired_and_inventory_pool_id"
  add_index "items", ["owner_id"], :name => "index_items_on_owner_id"
  add_index "items", ["parent_id", "retired"], :name => "index_items_on_parent_id_and_retired"
  add_index "items", ["retired"], :name => "index_items_on_retired"

  create_table "items_backup", :force => true do |t|
    t.string   "inventory_code"
    t.string   "serial_number"
    t.integer  "model_id"
    t.integer  "location_id"
    t.integer  "supplier_id"
    t.integer  "owner_id"
    t.integer  "parent_id"
    t.string   "invoice_number"
    t.date     "invoice_date"
    t.date     "last_check"
    t.date     "retired"
    t.string   "retired_reason"
    t.decimal  "price",                                 :precision => 8, :scale => 2
    t.boolean  "is_broken",                                                           :default => false
    t.boolean  "is_incomplete",                                                       :default => false
    t.boolean  "is_borrowable",                                                       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "needs_permission",                                                    :default => false
    t.integer  "inventory_pool_id"
    t.boolean  "is_inventory_relevant",                                               :default => false
    t.string   "responsible"
    t.string   "insurance_number"
    t.text     "note"
    t.text     "name"
    t.boolean  "delta",                                                               :default => true
    t.string   "user_name"
    t.string   "properties",            :limit => 2048
  end

  add_index "items_backup", ["delta"], :name => "index_items_on_delta"
  add_index "items_backup", ["inventory_code"], :name => "index_items_on_inventory_code", :unique => true
  add_index "items_backup", ["inventory_pool_id"], :name => "index_items_on_inventory_pool_id"
  add_index "items_backup", ["is_borrowable"], :name => "index_items_on_is_borrowable"
  add_index "items_backup", ["is_broken"], :name => "index_items_on_is_broken"
  add_index "items_backup", ["is_incomplete"], :name => "index_items_on_is_incomplete"
  add_index "items_backup", ["location_id"], :name => "index_items_on_location_id"
  add_index "items_backup", ["model_id", "retired", "inventory_pool_id"], :name => "index_items_on_model_id_and_retired_and_inventory_pool_id"
  add_index "items_backup", ["owner_id"], :name => "index_items_on_owner_id"
  add_index "items_backup", ["parent_id", "retired"], :name => "index_items_on_parent_id_and_retired"
  add_index "items_backup", ["retired"], :name => "index_items_on_retired"

  create_table "languages", :force => true do |t|
    t.string  "name"
    t.string  "locale_name"
    t.boolean "default"
    t.boolean "active"
  end

  add_index "languages", ["active", "default"], :name => "index_languages_on_active_and_default"
  add_index "languages", ["name"], :name => "index_languages_on_name", :unique => true

  create_table "locations", :force => true do |t|
    t.string  "room"
    t.string  "shelf"
    t.integer "building_id"
  end

  add_index "locations", ["building_id"], :name => "index_locations_on_building_id"

  create_table "model_group_links", :force => true do |t|
    t.integer "ancestor_id"
    t.integer "descendant_id"
    t.boolean "direct"
    t.integer "count"
    t.string  "label"
  end

  add_index "model_group_links", ["ancestor_id"], :name => "index_model_group_links_on_ancestor_id"
  add_index "model_group_links", ["descendant_id", "ancestor_id", "direct"], :name => "index_on_descendant_id_and_ancestor_id_and_direct"
  add_index "model_group_links", ["direct"], :name => "index_model_group_links_on_direct"

  create_table "model_groups", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "model_groups", ["type"], :name => "index_model_groups_on_type"

  create_table "model_groups_parents_backup", :id => false, :force => true do |t|
    t.integer "model_group_id"
    t.integer "parent_id"
    t.string  "label"
  end

  add_index "model_groups_parents_backup", ["model_group_id"], :name => "index_model_groups_parents_on_model_group_id"
  add_index "model_groups_parents_backup", ["parent_id"], :name => "index_model_groups_parents_on_parent_id"

  create_table "model_links", :force => true do |t|
    t.integer "model_group_id"
    t.integer "model_id"
    t.integer "quantity",       :default => 1
  end

  add_index "model_links", ["model_group_id", "model_id"], :name => "index_model_links_on_model_group_id_and_model_id"
  add_index "model_links", ["model_id", "model_group_id"], :name => "index_model_links_on_model_id_and_model_group_id"

  create_table "models", :force => true do |t|
    t.string   "name",                                                                  :null => false
    t.string   "manufacturer"
    t.text     "description"
    t.text     "internal_description"
    t.string   "info_url"
    t.decimal  "rental_price",         :precision => 8, :scale => 2
    t.integer  "maintenance_period",                                 :default => 0
    t.boolean  "is_package",                                         :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "technical_detail"
    t.text     "hand_over_note"
  end

  add_index "models", ["is_package"], :name => "index_models_on_is_package"

  create_table "models_compatibles", :id => false, :force => true do |t|
    t.integer "model_id"
    t.integer "compatible_id"
  end

  add_index "models_compatibles", ["compatible_id"], :name => "index_models_compatibles_on_compatible_id"
  add_index "models_compatibles", ["model_id"], :name => "index_models_compatibles_on_model_id"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.string   "title",      :default => ""
    t.datetime "created_at",                 :null => false
  end

  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "numerators", :force => true do |t|
    t.integer "item"
  end

  create_table "options", :force => true do |t|
    t.integer "inventory_pool_id"
    t.string  "inventory_code"
    t.string  "name"
    t.decimal "price",             :precision => 8, :scale => 2
  end

  add_index "options", ["inventory_pool_id"], :name => "index_options_on_inventory_pool_id"

  create_table "partitions", :force => true do |t|
    t.integer "model_id"
    t.integer "inventory_pool_id"
    t.integer "group_id"
    t.integer "quantity"
  end

  add_index "partitions", ["model_id", "inventory_pool_id", "group_id"], :name => "index_partitions_on_model_id_and_inventory_pool_id_and_group_id", :unique => true

  create_table "partitions_with_generals", :id => false, :force => true do |t|
    t.integer "model_id"
    t.integer "inventory_pool_id"
    t.integer "group_id"
    t.decimal "quantity",          :precision => 33, :scale => 0
  end

  create_table "properties", :force => true do |t|
    t.integer "model_id"
    t.string  "key"
    t.string  "value"
  end

  add_index "properties", ["model_id"], :name => "index_properties_on_model_id"

  create_table "purposes", :force => true do |t|
    t.text "description"
  end

  create_table "roles", :force => true do |t|
    t.integer "parent_id"
    t.integer "lft"
    t.integer "rgt"
    t.string  "name"
  end

  add_index "roles", ["lft"], :name => "index_roles_on_lft"
  add_index "roles", ["name"], :name => "index_roles_on_name"
  add_index "roles", ["parent_id"], :name => "index_roles_on_parent_id"
  add_index "roles", ["rgt"], :name => "index_roles_on_rgt"

  create_table "running_lines", :id => false, :force => true do |t|
    t.integer "id",                                      :default => 0,          :null => false
    t.string  "type",                                    :default => "ItemLine", :null => false
    t.integer "inventory_pool_id"
    t.integer "model_id"
    t.integer "quantity",                                :default => 1
    t.date    "start_date"
    t.date    "end_date"
    t.integer "is_late"
    t.date    "unavailable_from"
    t.binary  "concat_group_ids",  :limit => 2147483647
  end

  create_table "settings", :force => true do |t|
    t.string  "smtp_address"
    t.integer "smtp_port"
    t.string  "smtp_domain"
    t.string  "local_currency_string"
    t.text    "contract_terms"
    t.text    "contract_lending_party_string"
    t.string  "email_signature"
    t.string  "default_email"
    t.boolean "deliver_order_notifications"
    t.string  "user_image_url"
    t.string  "logo_url"
    t.string  "mail_delivery_method"
    t.string  "smtp_username"
    t.string  "smtp_password"
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
    t.integer  "authentication_system_id",                 :default => 1
    t.string   "unique_id"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "badge_id"
    t.string   "address"
    t.string   "city"
    t.string   "zip"
    t.string   "country"
    t.integer  "language_id"
    t.text     "extended_info"
    t.string   "settings",                 :limit => 1024
  end

  add_index "users", ["authentication_system_id"], :name => "index_users_on_authentication_system_id"

  create_table "visit_lines", :id => false, :force => true do |t|
    t.string  "visit_id",          :limit => 86
    t.integer "inventory_pool_id"
    t.integer "user_id"
    t.string  "status",            :limit => 11
    t.string  "action",            :limit => 9,  :default => "", :null => false
    t.date    "date"
    t.integer "quantity",                        :default => 1
    t.integer "contract_line_id",                :default => 0,  :null => false
  end

  create_table "visits", :id => false, :force => true do |t|
    t.string  "id",                :limit => 86
    t.integer "inventory_pool_id"
    t.integer "user_id"
    t.string  "status",            :limit => 11
    t.string  "action",            :limit => 9,                                 :default => "", :null => false
    t.date    "date"
    t.decimal "quantity",                        :precision => 32, :scale => 0
  end

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

  add_index "workdays", ["inventory_pool_id"], :name => "index_workdays_on_inventory_pool_id"

end
