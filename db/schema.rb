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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151001151820) do

  create_table "access_rights", force: :cascade do |t|
    t.integer  "user_id",           limit: 4
    t.integer  "inventory_pool_id", limit: 4
    t.date     "suspended_until"
    t.text     "suspended_reason",  limit: 65535
    t.date     "deleted_at"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "role",              limit: 17,    null: false
  end

  add_index "access_rights", ["deleted_at"], name: "index_access_rights_on_deleted_at", using: :btree
  add_index "access_rights", ["inventory_pool_id"], name: "index_access_rights_on_inventory_pool_id", using: :btree
  add_index "access_rights", ["role"], name: "index_access_rights_on_role", using: :btree
  add_index "access_rights", ["suspended_until"], name: "index_access_rights_on_suspended_until", using: :btree
  add_index "access_rights", ["user_id", "inventory_pool_id", "deleted_at"], name: "index_on_user_id_and_inventory_pool_id_and_deleted_at", using: :btree

  create_table "accessories", force: :cascade do |t|
    t.integer "model_id", limit: 4
    t.string  "name",     limit: 255
    t.integer "quantity", limit: 4
  end

  add_index "accessories", ["model_id"], name: "index_accessories_on_model_id", using: :btree

  create_table "accessories_inventory_pools", id: false, force: :cascade do |t|
    t.integer "accessory_id",      limit: 4
    t.integer "inventory_pool_id", limit: 4
  end

  add_index "accessories_inventory_pools", ["accessory_id", "inventory_pool_id"], name: "index_accessories_inventory_pools", unique: true, using: :btree
  add_index "accessories_inventory_pools", ["inventory_pool_id"], name: "index_accessories_inventory_pools_on_inventory_pool_id", using: :btree

  create_table "addresses", force: :cascade do |t|
    t.string "street",       limit: 255
    t.string "zip_code",     limit: 255
    t.string "city",         limit: 255
    t.string "country_code", limit: 255
    t.float  "latitude",     limit: 24
    t.float  "longitude",    limit: 24
  end

  add_index "addresses", ["street", "zip_code", "city", "country_code"], name: "index_addresses_on_street_and_zip_code_and_city_and_country_code", unique: true, using: :btree

  create_table "attachments", force: :cascade do |t|
    t.integer "model_id",     limit: 4
    t.boolean "is_main",                  default: false
    t.string  "content_type", limit: 255
    t.string  "filename",     limit: 255
    t.integer "size",         limit: 4
  end

  add_index "attachments", ["model_id"], name: "index_attachments_on_model_id", using: :btree

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",    limit: 4
    t.string   "auditable_type",  limit: 255
    t.integer  "associated_id",   limit: 4
    t.string   "associated_type", limit: 255
    t.integer  "user_id",         limit: 4
    t.string   "user_type",       limit: 255
    t.string   "username",        limit: 255
    t.string   "action",          limit: 255
    t.text     "audited_changes", limit: 65535
    t.integer  "version",         limit: 4,     default: 0
    t.string   "comment",         limit: 255
    t.string   "remote_address",  limit: 255
    t.string   "request_uuid",    limit: 255
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "authentication_systems", force: :cascade do |t|
    t.string  "name",       limit: 255
    t.string  "class_name", limit: 255
    t.boolean "is_default",             default: false
    t.boolean "is_active",              default: false
  end

  create_table "buildings", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "code", limit: 255
  end

  create_table "contracts", force: :cascade do |t|
    t.text     "note",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "database_authentications", force: :cascade do |t|
    t.string   "login",            limit: 255
    t.string   "crypted_password", limit: 40
    t.string   "salt",             limit: 40
    t.integer  "user_id",          limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "database_authentications", ["user_id"], name: "fk_rails_85650bffa9", using: :btree

  create_table "delegations_users", id: false, force: :cascade do |t|
    t.integer "delegation_id", limit: 4
    t.integer "user_id",       limit: 4
  end

  add_index "delegations_users", ["delegation_id"], name: "index_delegations_users_on_delegation_id", using: :btree
  add_index "delegations_users", ["user_id", "delegation_id"], name: "index_delegations_users_on_user_id_and_delegation_id", unique: true, using: :btree

  create_table "fields", force: :cascade do |t|
    t.text    "data",     limit: 65535
    t.boolean "active",                 default: true
    t.integer "position", limit: 4
  end

  add_index "fields", ["active"], name: "index_fields_on_active", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.integer  "inventory_pool_id",        limit: 4
    t.boolean  "is_verification_required",             default: false
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  add_index "groups", ["inventory_pool_id"], name: "index_groups_on_inventory_pool_id", using: :btree
  add_index "groups", ["is_verification_required"], name: "index_groups_on_is_verification_required", using: :btree

  create_table "groups_users", id: false, force: :cascade do |t|
    t.integer "user_id",  limit: 4
    t.integer "group_id", limit: 4
  end

  add_index "groups_users", ["group_id"], name: "index_groups_users_on_group_id", using: :btree
  add_index "groups_users", ["user_id", "group_id"], name: "index_groups_users_on_user_id_and_group_id", unique: true, using: :btree

  create_table "hidden_fields", force: :cascade do |t|
    t.string  "field_id", limit: 255
    t.integer "user_id",  limit: 4
  end

  create_table "holidays", force: :cascade do |t|
    t.integer "inventory_pool_id", limit: 4
    t.date    "start_date"
    t.date    "end_date"
    t.string  "name",              limit: 255
  end

  add_index "holidays", ["inventory_pool_id"], name: "index_holidays_on_inventory_pool_id", using: :btree
  add_index "holidays", ["start_date", "end_date"], name: "index_holidays_on_start_date_and_end_date", using: :btree

  create_table "images", force: :cascade do |t|
    t.integer "target_id",    limit: 4
    t.string  "target_type",  limit: 255
    t.boolean "is_main",                  default: false
    t.string  "content_type", limit: 255
    t.string  "filename",     limit: 255
    t.integer "size",         limit: 4
    t.integer "height",       limit: 4
    t.integer "width",        limit: 4
    t.integer "parent_id",    limit: 4
    t.string  "thumbnail",    limit: 255
  end

  add_index "images", ["target_id", "target_type"], name: "index_images_on_target_id_and_target_type", using: :btree

  create_table "inventory_pools", force: :cascade do |t|
    t.string  "name",                        limit: 255
    t.text    "description",                 limit: 65535
    t.string  "contact_details",             limit: 255
    t.string  "contract_description",        limit: 255
    t.string  "contract_url",                limit: 255
    t.string  "logo_url",                    limit: 255
    t.text    "default_contract_note",       limit: 65535
    t.string  "shortname",                   limit: 255
    t.string  "email",                       limit: 255
    t.text    "color",                       limit: 65535
    t.boolean "print_contracts",                           default: true
    t.text    "opening_hours",               limit: 65535
    t.integer "address_id",                  limit: 4
    t.boolean "automatic_suspension",                      default: false, null: false
    t.text    "automatic_suspension_reason", limit: 65535
    t.boolean "automatic_access"
    t.boolean "required_purpose",                          default: true
  end

  add_index "inventory_pools", ["address_id"], name: "fk_rails_6a55965722", using: :btree
  add_index "inventory_pools", ["name"], name: "index_inventory_pools_on_name", unique: true, using: :btree

  create_table "inventory_pools_model_groups", id: false, force: :cascade do |t|
    t.integer "inventory_pool_id", limit: 4
    t.integer "model_group_id",    limit: 4
  end

  add_index "inventory_pools_model_groups", ["inventory_pool_id"], name: "index_inventory_pools_model_groups_on_inventory_pool_id", using: :btree
  add_index "inventory_pools_model_groups", ["model_group_id"], name: "index_inventory_pools_model_groups_on_model_group_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "inventory_code",        limit: 255
    t.string   "serial_number",         limit: 255
    t.integer  "model_id",              limit: 4
    t.integer  "location_id",           limit: 4
    t.integer  "supplier_id",           limit: 4
    t.integer  "owner_id",              limit: 4,                                             null: false
    t.integer  "inventory_pool_id",     limit: 4,                                             null: false
    t.integer  "parent_id",             limit: 4
    t.string   "invoice_number",        limit: 255
    t.date     "invoice_date"
    t.date     "last_check"
    t.date     "retired"
    t.string   "retired_reason",        limit: 255
    t.decimal  "price",                               precision: 8, scale: 2
    t.boolean  "is_broken",                                                   default: false
    t.boolean  "is_incomplete",                                               default: false
    t.boolean  "is_borrowable",                                               default: false
    t.text     "status_note",           limit: 65535
    t.boolean  "needs_permission",                                            default: false
    t.boolean  "is_inventory_relevant",                                       default: false
    t.string   "responsible",           limit: 255
    t.string   "insurance_number",      limit: 255
    t.text     "note",                  limit: 65535
    t.text     "name",                  limit: 65535
    t.string   "user_name",             limit: 255
    t.text     "properties",            limit: 65535
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
  end

  add_index "items", ["inventory_code"], name: "index_items_on_inventory_code", unique: true, using: :btree
  add_index "items", ["inventory_pool_id"], name: "index_items_on_inventory_pool_id", using: :btree
  add_index "items", ["is_borrowable"], name: "index_items_on_is_borrowable", using: :btree
  add_index "items", ["is_broken"], name: "index_items_on_is_broken", using: :btree
  add_index "items", ["is_incomplete"], name: "index_items_on_is_incomplete", using: :btree
  add_index "items", ["location_id"], name: "index_items_on_location_id", using: :btree
  add_index "items", ["model_id", "retired", "inventory_pool_id"], name: "index_items_on_model_id_and_retired_and_inventory_pool_id", using: :btree
  add_index "items", ["owner_id"], name: "index_items_on_owner_id", using: :btree
  add_index "items", ["parent_id", "retired"], name: "index_items_on_parent_id_and_retired", using: :btree
  add_index "items", ["retired"], name: "index_items_on_retired", using: :btree
  add_index "items", ["supplier_id"], name: "fk_rails_538506beaf", using: :btree

  create_table "languages", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.string  "locale_name", limit: 255
    t.boolean "default"
    t.boolean "active"
  end

  add_index "languages", ["active", "default"], name: "index_languages_on_active_and_default", using: :btree
  add_index "languages", ["name"], name: "index_languages_on_name", unique: true, using: :btree

  create_table "locations", force: :cascade do |t|
    t.string  "room",        limit: 255
    t.string  "shelf",       limit: 255
    t.integer "building_id", limit: 4
  end

  add_index "locations", ["building_id"], name: "index_locations_on_building_id", using: :btree

  create_table "mail_templates", force: :cascade do |t|
    t.integer "inventory_pool_id", limit: 4
    t.integer "language_id",       limit: 4
    t.string  "name",              limit: 255
    t.string  "format",            limit: 255
    t.text    "body",              limit: 65535
  end

  create_table "model_group_links", force: :cascade do |t|
    t.integer "ancestor_id",   limit: 4
    t.integer "descendant_id", limit: 4
    t.boolean "direct"
    t.integer "count",         limit: 4
    t.string  "label",         limit: 255
  end

  add_index "model_group_links", ["ancestor_id"], name: "index_model_group_links_on_ancestor_id", using: :btree
  add_index "model_group_links", ["descendant_id", "ancestor_id", "direct"], name: "index_on_descendant_id_and_ancestor_id_and_direct", using: :btree
  add_index "model_group_links", ["direct"], name: "index_model_group_links_on_direct", using: :btree

  create_table "model_groups", force: :cascade do |t|
    t.string   "type",       limit: 255
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "model_groups", ["type"], name: "index_model_groups_on_type", using: :btree

  create_table "model_links", force: :cascade do |t|
    t.integer "model_group_id", limit: 4
    t.integer "model_id",       limit: 4
    t.integer "quantity",       limit: 4, default: 1
  end

  add_index "model_links", ["model_group_id", "model_id"], name: "index_model_links_on_model_group_id_and_model_id", using: :btree
  add_index "model_links", ["model_id", "model_group_id"], name: "index_model_links_on_model_id_and_model_group_id", using: :btree

  create_table "models", force: :cascade do |t|
    t.string   "type",                 limit: 255,                           default: "Model", null: false
    t.string   "manufacturer",         limit: 255
    t.string   "product",              limit: 255,                                             null: false
    t.string   "version",              limit: 255
    t.text     "description",          limit: 65535
    t.text     "internal_description", limit: 65535
    t.string   "info_url",             limit: 255
    t.decimal  "rental_price",                       precision: 8, scale: 2
    t.integer  "maintenance_period",   limit: 4,                             default: 0
    t.boolean  "is_package",                                                 default: false
    t.text     "technical_detail",     limit: 65535
    t.text     "hand_over_note",       limit: 65535
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
  end

  add_index "models", ["is_package"], name: "index_models_on_is_package", using: :btree
  add_index "models", ["type"], name: "index_models_on_type", using: :btree

  create_table "models_compatibles", id: false, force: :cascade do |t|
    t.integer "model_id",      limit: 4
    t.integer "compatible_id", limit: 4
  end

  add_index "models_compatibles", ["compatible_id"], name: "index_models_compatibles_on_compatible_id", using: :btree
  add_index "models_compatibles", ["model_id"], name: "index_models_compatibles_on_model_id", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "title",      limit: 255, default: ""
    t.datetime "created_at",                          null: false
  end

  add_index "notifications", ["created_at", "user_id"], name: "index_notifications_on_created_at_and_user_id", using: :btree
  add_index "notifications", ["user_id"], name: "index_notifications_on_user_id", using: :btree

  create_table "numerators", force: :cascade do |t|
    t.integer "item", limit: 4
  end

  create_table "options", force: :cascade do |t|
    t.integer "inventory_pool_id", limit: 4
    t.string  "inventory_code",    limit: 255
    t.string  "manufacturer",      limit: 255
    t.string  "product",           limit: 255,                         null: false
    t.string  "version",           limit: 255
    t.decimal "price",                         precision: 8, scale: 2
  end

  add_index "options", ["inventory_pool_id"], name: "index_options_on_inventory_pool_id", using: :btree

  create_table "partitions", force: :cascade do |t|
    t.integer "model_id",          limit: 4
    t.integer "inventory_pool_id", limit: 4
    t.integer "group_id",          limit: 4
    t.integer "quantity",          limit: 4
  end

  add_index "partitions", ["group_id"], name: "fk_rails_44495fc6cf", using: :btree
  add_index "partitions", ["inventory_pool_id"], name: "fk_rails_b10a540212", using: :btree
  add_index "partitions", ["model_id", "inventory_pool_id", "group_id"], name: "index_partitions_on_model_id_and_inventory_pool_id_and_group_id", unique: true, using: :btree

  create_table "partitions_with_generals", id: false, force: :cascade do |t|
    t.integer "model_id",          limit: 4
    t.integer "inventory_pool_id", limit: 4
    t.integer "group_id",          limit: 4
    t.decimal "quantity",                    precision: 33
  end

  create_table "properties", force: :cascade do |t|
    t.integer "model_id", limit: 4
    t.string  "key",      limit: 255
    t.string  "value",    limit: 255
  end

  add_index "properties", ["model_id"], name: "index_properties_on_model_id", using: :btree

  create_table "purposes", force: :cascade do |t|
    t.text "description", limit: 65535
  end

  create_table "reservations", force: :cascade do |t|
    t.integer  "contract_id",            limit: 4
    t.string   "type",                   limit: 255, default: "ItemLine", null: false
    t.integer  "item_id",                limit: 4
    t.integer  "model_id",               limit: 4
    t.integer  "quantity",               limit: 4,   default: 1
    t.date     "start_date"
    t.date     "end_date"
    t.date     "returned_date"
    t.integer  "option_id",              limit: 4
    t.integer  "purpose_id",             limit: 4
    t.integer  "returned_to_user_id",    limit: 4
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.integer  "inventory_pool_id",      limit: 4
    t.integer  "user_id",                limit: 4
    t.integer  "delegated_user_id",      limit: 4
    t.integer  "handed_over_by_user_id", limit: 4
    t.string   "status",                 limit: 11,                       null: false
  end

  add_index "reservations", ["contract_id"], name: "index_contract_lines_on_contract_id", using: :btree
  add_index "reservations", ["delegated_user_id"], name: "fk_rails_6f10314351", using: :btree
  add_index "reservations", ["end_date"], name: "index_contract_lines_on_end_date", using: :btree
  add_index "reservations", ["handed_over_by_user_id"], name: "fk_rails_3cc4562273", using: :btree
  add_index "reservations", ["inventory_pool_id"], name: "fk_rails_151794e412", using: :btree
  add_index "reservations", ["item_id"], name: "index_contract_lines_on_item_id", using: :btree
  add_index "reservations", ["model_id"], name: "index_contract_lines_on_model_id", using: :btree
  add_index "reservations", ["option_id"], name: "index_contract_lines_on_option_id", using: :btree
  add_index "reservations", ["purpose_id"], name: "fk_rails_f33ca08ef1", using: :btree
  add_index "reservations", ["returned_date", "contract_id"], name: "index_contract_lines_on_returned_date_and_contract_id", using: :btree
  add_index "reservations", ["returned_to_user_id"], name: "fk_rails_2b7f188fdb", using: :btree
  add_index "reservations", ["start_date"], name: "index_contract_lines_on_start_date", using: :btree
  add_index "reservations", ["status"], name: "index_reservations_on_status", using: :btree
  add_index "reservations", ["type", "contract_id"], name: "index_contract_lines_on_type_and_contract_id", using: :btree
  add_index "reservations", ["user_id"], name: "fk_rails_48a92fce51", using: :btree

  create_table "settings", force: :cascade do |t|
    t.string  "smtp_address",                   limit: 255
    t.integer "smtp_port",                      limit: 4
    t.string  "smtp_domain",                    limit: 255
    t.string  "local_currency_string",          limit: 255
    t.text    "contract_terms",                 limit: 65535
    t.text    "contract_lending_party_string",  limit: 65535
    t.string  "email_signature",                limit: 255
    t.string  "default_email",                  limit: 255
    t.boolean "deliver_order_notifications"
    t.string  "user_image_url",                 limit: 255
    t.string  "ldap_config",                    limit: 255
    t.string  "logo_url",                       limit: 255
    t.string  "mail_delivery_method",           limit: 255
    t.string  "smtp_username",                  limit: 255
    t.string  "smtp_password",                  limit: 255
    t.boolean "smtp_enable_starttls_auto",                    default: false,  null: false
    t.string  "smtp_openssl_verify_mode",       limit: 255,   default: "none", null: false
    t.string  "time_zone",                      limit: 255,   default: "Bern", null: false
    t.boolean "disable_manage_section",                       default: false,  null: false
    t.text    "disable_manage_section_message", limit: 65535
    t.boolean "disable_borrow_section",                       default: false,  null: false
    t.text    "disable_borrow_section_message", limit: 65535
    t.text    "text",                           limit: 65535
    t.integer "timeout_minutes",                limit: 4,     default: 30,     null: false
  end

  create_table "suppliers", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "suppliers", ["name"], name: "index_suppliers_on_name", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "login",                    limit: 255
    t.string   "firstname",                limit: 255
    t.string   "lastname",                 limit: 255
    t.string   "phone",                    limit: 255
    t.integer  "authentication_system_id", limit: 4,     default: 1
    t.string   "unique_id",                limit: 255
    t.string   "email",                    limit: 255
    t.string   "badge_id",                 limit: 255
    t.string   "address",                  limit: 255
    t.string   "city",                     limit: 255
    t.string   "zip",                      limit: 255
    t.string   "country",                  limit: 255
    t.integer  "language_id",              limit: 4
    t.text     "extended_info",            limit: 65535
    t.string   "settings",                 limit: 1024
    t.integer  "delegator_user_id",        limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "users", ["authentication_system_id"], name: "index_users_on_authentication_system_id", using: :btree
  add_index "users", ["delegator_user_id"], name: "fk_rails_cc67a09e58", using: :btree
  add_index "users", ["language_id"], name: "fk_rails_45f4f12508", using: :btree

  create_table "visits", id: false, force: :cascade do |t|
    t.string  "id",                limit: 148
    t.integer "inventory_pool_id", limit: 4
    t.integer "user_id",           limit: 4
    t.string  "status",            limit: 11,                 null: false
    t.date    "date"
    t.decimal "quantity",                      precision: 32
  end

  create_table "workdays", force: :cascade do |t|
    t.integer "inventory_pool_id",        limit: 4
    t.boolean "monday",                                 default: true
    t.boolean "tuesday",                                default: true
    t.boolean "wednesday",                              default: true
    t.boolean "thursday",                               default: true
    t.boolean "friday",                                 default: true
    t.boolean "saturday",                               default: false
    t.boolean "sunday",                                 default: false
    t.integer "reservation_advance_days", limit: 4,     default: 0
    t.text    "max_visits",               limit: 65535
  end

  add_index "workdays", ["inventory_pool_id"], name: "index_workdays_on_inventory_pool_id", using: :btree

  add_foreign_key "access_rights", "inventory_pools", on_delete: :cascade
  add_foreign_key "access_rights", "users"
  add_foreign_key "accessories", "models", on_delete: :cascade
  add_foreign_key "accessories_inventory_pools", "accessories"
  add_foreign_key "accessories_inventory_pools", "inventory_pools"
  add_foreign_key "attachments", "models", on_delete: :cascade
  add_foreign_key "database_authentications", "users", on_delete: :cascade
  add_foreign_key "delegations_users", "users"
  add_foreign_key "delegations_users", "users", column: "delegation_id"
  add_foreign_key "groups", "inventory_pools"
  add_foreign_key "groups_users", "groups"
  add_foreign_key "groups_users", "users"
  add_foreign_key "holidays", "inventory_pools", on_delete: :cascade
  add_foreign_key "inventory_pools", "addresses"
  add_foreign_key "inventory_pools_model_groups", "inventory_pools"
  add_foreign_key "inventory_pools_model_groups", "model_groups"
  add_foreign_key "items", "inventory_pools"
  add_foreign_key "items", "inventory_pools", column: "owner_id"
  add_foreign_key "items", "items", column: "parent_id", on_delete: :nullify
  add_foreign_key "items", "locations"
  add_foreign_key "items", "models"
  add_foreign_key "items", "suppliers"
  add_foreign_key "locations", "buildings"
  add_foreign_key "model_group_links", "model_groups", column: "ancestor_id", on_delete: :cascade
  add_foreign_key "model_group_links", "model_groups", column: "descendant_id", on_delete: :cascade
  add_foreign_key "model_links", "model_groups", on_delete: :cascade
  add_foreign_key "model_links", "models", on_delete: :cascade
  add_foreign_key "models_compatibles", "models"
  add_foreign_key "models_compatibles", "models", column: "compatible_id"
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "options", "inventory_pools"
  add_foreign_key "partitions", "groups"
  add_foreign_key "partitions", "inventory_pools"
  add_foreign_key "partitions", "models", on_delete: :cascade
  add_foreign_key "properties", "models", on_delete: :cascade
  add_foreign_key "reservations", "contracts", on_delete: :cascade
  add_foreign_key "reservations", "inventory_pools"
  add_foreign_key "reservations", "items"
  add_foreign_key "reservations", "models"
  add_foreign_key "reservations", "options"
  add_foreign_key "reservations", "purposes"
  add_foreign_key "reservations", "users"
  add_foreign_key "reservations", "users", column: "delegated_user_id"
  add_foreign_key "reservations", "users", column: "handed_over_by_user_id"
  add_foreign_key "reservations", "users", column: "returned_to_user_id"
  add_foreign_key "users", "authentication_systems"
  add_foreign_key "users", "languages"
  add_foreign_key "users", "users", column: "delegator_user_id"
  add_foreign_key "workdays", "inventory_pools", on_delete: :cascade
end
