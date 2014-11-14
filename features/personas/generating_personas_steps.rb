include EvalHelpers

#######################################################################

Given(/^today is a random date$/) do
  d1 = Date.today

  Dataset.use_test_datetime(reset: true, freeze: true)
  expect(ENV['TEST_DATETIME']).not_to be_empty

  @random_date = Date.today
  expect(d1).not_to eq @random_date
end

Given(/^today is "(.*)"$/) do |date_to_eval|
  d1 = Time.parse(substitute_with_eval(date_to_eval))
  Dataset.back_to_date(d1)
  expect(d1).not_to eq @random_date
end

Given(/^today is back to initial random date$/) do
  Dataset.back_to_date
  expect(Date.today).to eq @random_date
end

Given(/^no dump is existing$/) do
  dir = File.join(Rails.root, "features/personas/dumps")
  system "rm -r #{dir}"
  system "mkdir -p #{dir}"
  expect(Dir.glob(File.join(dir, "*"))).to be_empty
end

Given(/^the minimal setup exists$/) do
  `RAILS_ENV=test rake db:drop db:create db:migrate`

  FactoryGirl.create :setting
  LeihsFactory.create_default_languages
  LeihsFactory.create_default_authentication_systems
end

Then(/^the (minimal seed|current time) dump is generated$/) do |arg1|
  config = Rails.configuration.database_configuration[Rails.env]
  file_name = Dataset.dump_file_name(arg1 == "minimal seed")

  expect(File.exists?(file_name)).to be false

  system "mysqldump #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil}  #{config['database']} --no-create-db | grep -v 'SQL SECURITY DEFINER' > #{file_name}"

  expect(File.exists?(file_name)).to be true
end

Then(/^the minimal seed dump is loaded$/) do
  `RAILS_ENV=test rake db:drop db:create`

  config = Rails.configuration.database_configuration[Rails.env]
  file_name = Dataset.dump_file_name(true)

  expect(File.exists?(file_name)).to be true

  cmd = "mysql #{config['host'] ? "-h #{config['host']}" : nil} -u #{config['username']} #{config['password'] ? "--password=#{config['password']}" : nil} #{config['database']} < #{file_name}"

  # we need this variable assignment in order to wait for the end of the system call. DO NOT DELETE !
  dump_restored = system(cmd)
  raise "persona dump not loaded" unless dump_restored

  # ensure the settings are initialized
  Setting.initialize_constants
end

Given(/^(\d+) user(s)? exist(s)?$/) do |n, s1, s2|
  n.to_i.times do
    FactoryGirl.create :user
  end
end

Given(/^the following users exist$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|

    attrs = {language: Language.find_by_locale_name(hash_row["language"]),
             firstname: hash_row["firstname"],
             lastname: hash_row["lastname"],
             login: hash_row["firstname"].downcase,
             email: hash_row["email"],
             address: hash_row["address"]}

    FactoryGirl.create(:user, attrs)
  end
end

Given(/^the following inventory pools exist$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    FactoryGirl.create(:inventory_pool,
                       name: hash_row["name"],
                       shortname: hash_row["shortname"],
                       email: hash_row["email"],
                       description: hash_row["description"],
                       contact_details: hash_row["contact_details"],
                       contract_description: hash_row["contact_description"],
                       default_contract_note: Faker::Lorem.sentence,
                       automatic_suspension: hash_row["automatic_suspension"] == "true",
                       automatic_suspension_reason: hash_row["automatic_suspension"] == "true" ? Faker::Lorem.sentence : nil)
  end
end

def create_access_right(user, inventory_pool_name, role)
  inventory_pool = unless inventory_pool_name
                     if role == :admin
                       nil
                     else
                       FactoryGirl.create(:inventory_pool)
                     end
                   else
                     InventoryPool.find_by_name inventory_pool_name
                   end
  user.access_rights.create(role: role,
                            inventory_pool: inventory_pool)

end

Given(/^the following access rights exist$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    target = if hash_row["user email"]
               User.find_by_email hash_row["user email"]
             elsif hash_row["delegation name"]
               User.as_delegations.find_by_firstname hash_row["delegation name"]
             end
    expect(target).not_to be_nil
    ar = create_access_right(target, hash_row["inventory pool"], hash_row["role"].to_sym)
    ar.update_attributes(deleted_at: hash_row["deleted at"]) if hash_row["deleted at"]
    ar.update_attributes(suspended_until: hash_row["suspended until"], suspended_reason: hash_row["suspended reason"]) if hash_row["suspended until"]
  end
end

Given(/^users with the following access rights exist$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    user = FactoryGirl.create :user
    create_access_right(user, hash_row["inventory pool"], hash_row["role"].to_sym)
  end
end

Given(/^the following delegations exist$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    FactoryGirl.create(:user,
                       delegator_user: User.find_by_email(hash_row["delegator user email"]),
                       firstname: hash_row["name"],
                       lastname: nil,
                       login: nil,
                       phone: nil,
                       authentication_system: nil,
                       unique_id: nil,
                       email: nil,
                       badge_id: nil,
                       address: nil,
                       city: nil,
                       country: nil,
                       zip: nil,
                       language: nil)
  end
end

Given(/^the following delegations have following delegated users$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    User.as_delegations.find_by_firstname(hash_row["delegation name"]).delegated_users << User.find_by_email(hash_row["user email"])
  end
end

Given(/^the following workdays exist$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    inventory_pool = InventoryPool.find_by_name hash_row["inventory pool"]
    inventory_pool.workday.update_attributes(monday:    hash_row["monday"],
                                             tuesday:   hash_row["tuesday"],
                                             wednesday: hash_row["wednesday"],
                                             thursday:  hash_row["thursday"],
                                             friday:    hash_row["friday"],
                                             saturday:  hash_row["saturday"],
                                             sunday:    hash_row["sunday"],
                                             reservation_advance_days: hash_row["reservation_advance_days"],
                                             max_visits: JSON.parse(hash_row["max_visits"]))
  end
end

Given(/^the following holidays exist$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    inventory_pool = InventoryPool.find_by_name hash_row["inventory pool"]
    sd = hash_row["start date"].split('.')
    ed = hash_row["end date"].split('.')
    if sd[2] == "xxxx" and ed[2] == "xxxx"
      # NOTE we consider xxxx as this year and next year
      (0..1).each do |n|
        start_date = Date.new(Date.today.year + n, sd[1].to_i, sd[0].to_i)
        end_date = Date.new(Date.today.year + n, ed[1].to_i, ed[0].to_i)
        inventory_pool.holidays.create(start_date: start_date,
                                       end_date: end_date,
                                       name: hash_row["name"])
      end
    else
      raise "not implemented"
    end
  end
end

Given(/^(\d+) (unsubmitted|submitted|approved) contracts?(?: for user "(.*)")? exists?$/) do |n, status, user_email|
  attrs = {status: status.to_sym}
  attrs[:user] = User.find_by_email(user_email) if user_email

  n.to_i.times do
    attrs[:inventory_pool] = attrs[:user].inventory_pools.sample if attrs[:user]
    FactoryGirl.create :contract_with_lines, attrs
  end
end

Given(/^users with deleted access rights and closed contracts exist$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    hash_row["quantity users"].to_i.times do
      user = FactoryGirl.create(:user)
      inventory_pool = InventoryPool.find_by_name hash_row["inventory pool"]
      FactoryGirl.create :access_right, inventory_pool: inventory_pool, deleted_at: Date.today, user: user, role: :customer
      contract = FactoryGirl.create :contract_with_lines, inventory_pool: inventory_pool, status: :approved, user: user
      manager = User.find_by_login "ramon"
      contract.sign(manager)
      contract.lines.each { |cl| cl.update_attributes(returned_date: Date.today, returned_to_user_id: manager.id) }
      contract.close
    end
  end
end

Given(/^the following building exists:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    FactoryGirl.create(:building, name: hash_row["name"], code: hash_row["code"])
  end
end

Given(/^the following location exists:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    building = Building.find_by_code hash_row["building code"]
    FactoryGirl.create(:location, room: hash_row["room"], shelf: hash_row["shelf"], building: building)
  end
end

Given(/^the following models exist:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    attrs = {product: hash_row["product"],
             version: hash_row["version"],
             manufacturer: hash_row["manufacturer"]
    }

    attrs[:description] = hash_row["description"] if hash_row["description"]
    attrs[:hand_over_note] = hash_row["hand over note"] if hash_row["hand over note"]
    attrs[:maintenance_period] = hash_row["maintenance period"] if hash_row["maintenance period"]

    FactoryGirl.create(:model, attrs)
  end
end

Given(/^the following categories have the following models:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    category = Category.find_or_create_by(name: hash_row["category name"])
    model = Model.find_by_name(hash_row["model name"])
    category.models << model
    expect(model.categories).to include category
  end
end

Given(/^the following items exists:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    building = Building.find_by_code hash_row["building code"]

    attrs = {model: Model.find_by_name(hash_row["product name"]),
             location: Location.where(room: hash_row["location room"], shelf: hash_row["location shelf"], building_id: building.try(:id)).first,
             owner: InventoryPool.find_by_name(hash_row["owner name"]),
             inventory_code: hash_row["inventory code"],
             serial_number: hash_row["serial number"],
             name: hash_row["name"],
             retired_reason: hash_row["retired reason"],
    }

    attrs[:retired] = Date.parse(hash_row["retired"]) if hash_row["retired"]
    attrs[:is_borrowable] = (hash_row["is borrowable"] == "true") if hash_row["is borrowable"]
    attrs[:is_broken] = (hash_row["is broken"] == "true") if hash_row["is broken"]
    attrs[:is_incomplete] = (hash_row["is incomplete"] == "true") if hash_row["is incomplete"]
    attrs[:inventory_pool] = InventoryPool.find_by_name(hash_row["inventory pool name"]) if hash_row["inventory pool name"]

    FactoryGirl.create(:item, attrs)
  end
end

Given(/^the following groups exist:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    inventory_pool = InventoryPool.find_by_name hash_row["inventory pool"]
    FactoryGirl.create(:group, name: hash_row["name"], inventory_pool: inventory_pool, is_verification_required: (hash_row["verification required"] == "true"))
  end
end

Given(/^the group "(.*)" hast following users:$/) do |group_name, table|
  group = Group.find_by_name group_name
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    group.users << User.find_by_email(hash_row["user email"])
  end
end

Given(/^the following categories exist:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    group = Category.find_by_name hash_row["name"]
    group ||= FactoryGirl.create(:category, name: hash_row["name"])
    if hash_row["parent name"]
      parent = Category.find_by_name hash_row["parent name"]
      parent.children << group
    end
  end
end

Given(/^there exists (\d+) models of category "(.*?)" each with (\d+) item with following properties:$/) do |models_quantity, category_name, items_quantity, table|
  category = Category.find_by_name(category_name)

  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    building = Building.find_by_code hash_row["building code"]
    location = Location.where(room: hash_row["room"], shelf: hash_row["shelf"], building_id: building.id).first
    inventory_pool = InventoryPool.find_by_name hash_row["inventory pool"]
    manufacturer = hash_row["model manufacturer"]
    hand_over_note = hash_row["model hand over note"]

    (1..models_quantity.to_i).to_a.each do |i|
      model = FactoryGirl.create(:model, :product => "#{category_name} #{i} #{Faker::Lorem.word}",
                                 :manufacturer => manufacturer,
                                 :hand_over_note => hand_over_note,
                                 :maintenance_period => 0)
      model.model_links.create :model_group => category
      FactoryGirl.create(:item, :model => model, :location => location, :owner => inventory_pool)
    end
  end
end

Given(/^the following partitions exist:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    inventory_pool = InventoryPool.find_by_name hash_row["inventory pool name"]
    group = Group.find_by_name hash_row["group name"]
    model = Model.find_by_name hash_row["model name"]
    model.partitions << Partition.create(model: model,
                                         inventory_pool: inventory_pool,
                                         group: group,
                                         quantity: 1)
  end
end

Given(/^the following options exist:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    inventory_pool = InventoryPool.find_by_name hash_row["inventory pool name"]
    FactoryGirl.create(:option,
                       :product => hash_row["product name"],
                       :inventory_pool => inventory_pool,
                       :inventory_code => hash_row["inventory code"])
  end
end

Given(/^template "(.*?)" with the following quantities exists:$/) do |template_name, table|
  template = FactoryGirl.build(:template, :name => template_name)
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    model = Model.find_by_name hash_row["model name"]
    template.model_links << FactoryGirl.build(:model_link, :model_group => template, :model => model, :quantity => 1)
  end
  template.save
end

Given(/^the template "(.*?)" is used in the inventory pool "(.*?)"$/) do |template_name, inventory_pool_name|
  template = Template.find_by_name template_name
  inventory_pool = InventoryPool.find_by_name inventory_pool_name
  template.inventory_pools << inventory_pool
  template.save
end

Given(/^the following package model with (\d+) items? exists:$/) do |items_quantity, table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    package = Model.find_by_name(hash_row["product name"]) || FactoryGirl.create(:package_model, product: hash_row["product name"])
    inventory_pool = InventoryPool.find_by_name hash_row["inventory pool name"]
    items_quantity.to_i.times do
      package.items << FactoryGirl.create(:package_item_with_parts, owner: inventory_pool, inventory_pool: inventory_pool)
    end
  end
end

Given(/^the model "(.*?)" has the following properties:$/) do |model_name, table|
  model = Model.find_by_name model_name
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    model.properties << Property.create(:key => hash_row["key"], :value => hash_row["value"])
  end
end

Given(/^the model "(.*?)" has the following compatibles:$/) do |model_name, table|
  model = Model.find_by_name model_name
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    compatible = Model.find_by_name hash_row["model name"]
    model.compatibles << compatible
  end
end

Given(/^the model "(.*?)" has (\d+) attachments?$/) do |model_name, attachment_quantity|
  model = Model.find_by_name model_name
  attachment_quantity.to_i.times do
    model.attachments << FactoryGirl.create(:attachment)
  end
end

Given(/^the (category|model) "(.*?)" has (\d+) images?$/) do |type, name, image_quantity|
  klass = type.capitalize.constantize
  obj = klass.find_by_name name
  obj.images << FactoryGirl.create(:image, target: obj) if image_quantity.to_i > 0
  if (counter = image_quantity.to_i - 1) > 0
    counter.to_i.times do
      obj.images << FactoryGirl.create(:image, :another, target: obj)
    end
  end
end

Given(/^there exist more than (\d+) and less then (\d+) arbitrary licenses for the inventory pool "(.*?)"$/) do |lower_border, upper_border, ip_name|
  ip = InventoryPool.find_by_name ip_name
  rand(lower_border.to_i..upper_border.to_i).times { FactoryGirl.create :license, owner: ip, is_borrowable: [true, false].sample }
end

Given(/^the following licenses exist:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    attrs = {owner: InventoryPool.find_by_name(hash_row["owner name"]),
             retired_reason: hash_row["retired reason"],
             properties: {license_expiration: hash_row["license expiration"],
                          license_type: hash_row["license type"],
                          operating_system: hash_row["operating system"].try(:split, ','),
                          maintenance_contract: hash_row["maintenance contract"],
                          maintenance_expiration: hash_row["maintenance expiration"]},
             inventory_code: hash_row["inventory code"],
             inventory_pool: (hash_row["inventory pool name"] and InventoryPool.find_by_name(hash_row["inventory pool name"]))}

    attrs[:retired] = Date.parse(hash_row["retired"]) if hash_row["retired"]
    attrs[:invoice_date] = Date.parse(hash_row["invoice date"]) if hash_row["invoice date"]
    attrs[:is_borrowable] = (hash_row["is borrowable"] == "true") if hash_row["is borrowable"]
    attrs[:model] = Software.find_by_name(hash_row["software name"]) if hash_row["software name"]

    FactoryGirl.create :license, attrs
  end
end

Given(/^the following software exist:$/) do |table|
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    FactoryGirl.create(:software, product: hash_row["product"], technical_detail: hash_row["technical detail"])
  end
end

Given(/^the software "(.*?)" has from (\d+) to (\d+) attachments$/) do |software_name, lower_border, upper_border|
  software = Software.find_by_name software_name
  rand(lower_border.to_i..upper_border.to_i).times do
    software.attachments << FactoryGirl.create(:attachment)
  end
end

Given(/^the license with inventory code "(.*?)" has to following quantity allocations:$/) do |inv_code, table|
  license = Item.find_by_inventory_code inv_code
  license.properties["quantity_allocations"] = []
  hashes_with_evaled_and_nilified_values(table).each do |hash_row|
    license.properties["quantity_allocations"] << {room: hash_row["room"], quantity: hash_row["quantity"]}
  end
  license.save
end

Given(/^each of the models has from (\d+) to (\d+) accessories possibly activated for the inventory pool "(.*?)"$/) do |lower_border, upper_border, ip_name|
  ip = InventoryPool.find_by_name ip_name
  Model.all.each do |model|
    rand(lower_border.to_i..upper_border.to_i).times do
      accessory = FactoryGirl.create :accessory, :model => model
      ip.accessories << accessory if rand() > 0.5
    end
  end
end

Given(/^an? (submitted|approved|rejected) contract with following properties exist:$/) do |status, table|
  attrs = {status: status.to_sym}
  table.rows_hash.each_pair do |key, value|
    case key
      when "user email"
        attrs[:user] = User.find_by_email value
      when "delegation name"
        attrs[:user] = User.as_delegations.find_by_firstname value
      when "delegated user email"
        attrs[:delegated_user] = User.find_by_email value
      when "inventory pool name"
        attrs[:inventory_pool] = InventoryPool.find_by_name value
      else
        raise
    end
  end
  @contract = FactoryGirl.create(:contract, attrs)
  expect(@contract.valid?).to be true
end

Given(/^this contract has from (\d+) to (\d+) (item|license|option) lines:$/) do |from, to, line_type, table|
  attrs = {
      contract: @contract
  }

  # initialize variables accessed later in the block scope
  assigned = false
  item = nil
  option = nil

  properties = table.rows_hash
  properties.each_pair do |key, value|
    value = substitute_with_eval value
    case key
      when "", "item location"
        # do nothing
      when "assigned"
        assigned = value == "true"
      when "start date"
        attrs[:start_date] = Date.parse(value)
      when "end date"
        attrs[:end_date] = Date.parse(value)
      when "returned date"
        attrs[:returned_date] = Date.parse(value)
      when "returned to user"
        attrs[:returned_to_user] = User.find_by_email value
      when "quantity"
        attrs[:quantity] = value.to_i
      when "model name"
        attrs[:model] = Model.find_by_name(value)
      when "model package name"
        attrs[:model] = Model.packages.find_by_name(value)
      when "item"
        case value
          when "in_stock"
            attrs[:item] = @contract.inventory_pool.items.in_stock.where(:model_id => attrs[:model]).first
          when "owned"
            h = {owner: @contract.inventory_pool}
            if properties["item location"] == "nil"
              h[:location] = nil
            end
            attrs[:item] = FactoryGirl.create(:item, h)
            attrs[:model] = attrs[:item].model
          else
            attrs[:item] = @contract.inventory_pool.items.find_by_inventory_code(value)
            attrs[:model] = attrs[:item].model
        end
      when "inventory code"
        if line_type == "option"
          option = Option.find_by_inventory_code value
        elsif line_type == "item" or line_type == "license"
          item = Item.find_by_inventory_code value
        end
      when "purpose"
        attrs[:purpose] = FactoryGirl.create(:purpose, :description => value)
      when "real overbooking"
        if value == "true"
          from = to = attrs[:model].borrowable_items.where(inventory_pool_id: @contract.inventory_pool).count + 1
        end
      when "soft overbooking"
        if value == "true"
          availability = attrs[:model].availability_in @contract.inventory_pool
          attrs[:start_date] = availability.changes.first.first
          from = to = 1 + availability.changes.first.second[nil][:in_quantity]
        end
      else
        raise
    end
  end

  attrs[:purpose] ||= FactoryGirl.create(:purpose)

  rand(from.to_i..to.to_i).times do
    @contract.contract_lines << if line_type == "item" or line_type == "license"
                                  attrs1 = if attrs[:model]
                                             attrs
                                           else
                                             item ||= FactoryGirl.create line_type.to_sym, inventory_pool: @contract.inventory_pool
                                             attrs2 = attrs.merge(model: item.model)
                                             attrs2[:item] = item if assigned
                                             item = nil # reset to nil in order to regenerate a new one later in the loop
                                             attrs2
                                           end
                                  FactoryGirl.create(:contract_line, attrs1)
                                elsif line_type == "option"
                                  option ||= FactoryGirl.create :option, inventory_pool: @contract.inventory_pool
                                  attrs1 = attrs.merge(model: option.model)
                                  option = nil # reset to nil in order to regenerate a new one later in the loop
                                  FactoryGirl.create(:option_line, attrs1)
                                end
  end

  expect(@contract.reload.valid?).to be true
  expect(@contract.lines.all?(&:item)).to be true if assigned
end

Given(/^this contract is signed by "(.*?)"$/) do |user_email|
  @contract.reload.sign User.find_by_email(user_email)
  expect(@contract.reload.status).to be :signed
end

Given(/^this contract is closed on "(.*?)" by "(.*?)"$/) do |date_eval, user_email|
  date = substitute_with_eval date_eval
  user = User.find_by_email user_email
  @contract.lines.each { |cl| cl.update_attributes(returned_date: date, returned_to_user_id: user) }
  @contract.close
  expect(@contract.reload.status).to be :closed
end

Given(/^the item with inventory code "(.*?)" has now the following properties:$/) do |inv_code, table|
  item = Item.find_by_inventory_code inv_code
  attrs = {}
  table.rows_hash.each_pair do |key, value|
    value = substitute_with_eval value
    case key
      when ""
        # do nothing
      when "retired"
        attrs[:retired] = Date.parse(value)
      when "retired reason"
        attrs[:retired_reason] = value
      when "inventory pool name"
        attrs[:inventory_pool] = InventoryPool.find_by_name value
      when "owner name"
        attrs[:owner] = InventoryPool.find_by_name value
      else
        raise
    end
  end
  item.update_attributes attrs
end

Then(/^there are (\d+) (.*) in total$/) do |n, elements|
  expect(
      case elements
        when "inventory pools"
          InventoryPool.count
        when "users"
          User.not_as_delegations.count
        when "delegations"
          User.as_delegations.count
        when "access rights"
          AccessRight.count
        when "workdays"
          Workday.count
        when "holidays"
          Holiday.count
        when "buildings"
          Building.count
        when "locations"
          Location.count
        when "options"
          Option.count
        when "models"
          Model.count
        when "package models"
          Model.packages.count
        when "items"
          Item.items.count
        when "retired items"
          Item.items.retired.count
        when "broken items"
          Item.items.broken.count
        when "incomplete items"
          Item.items.incomplete.count
        when "licences"
          Item.licences.count
        when "categories"
          Category.count
        when "templates"
          Template.count
        when "groups"
          Group.count
        when "partitions"
          Partition.count
        when "contracts"
          Contract.count
      end
  ).to eq n.to_i
end
