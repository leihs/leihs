# -*- encoding : utf-8 -*-

class Field < ActiveHash::Base
  include ActiveHash::Associations

  belongs_to :parent, :class_name => "Field", :foreign_key => "visibility_dependency_field_id"
  has_many :children, :class_name => "Field", :foreign_key => "visibility_dependency_field_id"
  
  self.data = [
    {
      id: 1,
      label: "Inventory Code",
      attribute: "inventory_code",
      required: true,
      permissions: {role: :inventory_manager, owner: true},
      type: "text",
      group: nil
    },{
      id: 2,
      label: "Serial Number",
      attribute: "serial_number",
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      group: "General Information"
    },{
      id: 3,
      label: "MAC-Address",
      attribute: ["properties", "mac_address"],
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      group: "General Information"
    },{
      id: 4,
      label: "IMEI-Number",
      attribute: ["properties", "imei_number"],
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      group: "General Information"
    },{
      id: 5,
      label: "Name",
      attribute: "name",
      type: "text",
      group: "General Information",
      forPackage: true
    },{
      id: 6,
      label: "Note",
      attribute: "note",
      type: "textarea",
      group: "General Information",
      forPackage: true
    },{
      id: 7,
      label: "Retirement",
      attribute: "retired",
      type: "select",
      permissions: {role: :lending_manager, owner: true},
      values: [{label: "No", value: false}, {label: "Yes", value: true}],
      group: "Status"
    },{
      id: 8,
      label: "Reason for Retirement",
      attribute: "retired_reason",
      type: "textarea",
      required: true,
      permissions: {role: :lending_manager, owner: true},
      visibility_dependency_field_id: 7,
      visibility_dependency_value: "true",
      group: "Status"
    },{
      id: 9,
      label: "Working order",
      attribute: "is_broken",
      type: "radio",
      values: [{label: "OK", value: false}, {label: "Broken", value: true}],
      default: false,
      group: "Status",
      forPackage: true
    },{
      id: 10,
      label: "Completeness",
      attribute: "is_incomplete",
      type: "radio",
      values: [{label: "OK", value: false}, {label: "Incomplete", value: true}],
      default: false,
      group: "Status",
      forPackage: true
    },{
      id: 11,
      label: "Borrowable",
      attribute: "is_borrowable",
      type: "radio",
      values: [{label: "OK", value: true}, {label: "Unborrowable", value: false}],
      default: false,
      group: "Status",
      forPackage: true
    },{
      id: 12,
      label: "Building",
      attribute: ["location", "building_id"],
      type: "autocomplete",
      values: lambda{([{:value => nil, :label => _("None")}] + Building.all.map {|x| {:value => x.id, :label => x.to_s}}).as_json},
      group: "Location",
      forPackage: true
    },{
      id: 13,
      label: "Room",
      attribute: ["location", "room"],
      type: "text",
      group: "Location",
      forPackage: true
    },{
      id: 14,
      label: "Shelf",
      attribute: ["location", "shelf"],
      type: "text",
      group: "Location",
      forPackage: true
    },{
      id: 15,
      label: "Relevant for inventory",
      attribute: "is_inventory_relevant",
      type: "select",
      permissions: {role: :inventory_manager, owner: true},
      values: [{label: "No", value: false}, {label: "Yes", value: true}],
      default: true,
      group: "Inventory",
      forPackage: true
    },{
      id: 36,
      label: "Anschaffungskategorie",
      attribute: ["properties", "anschaffungskategorie"],
      value_label: ["properties", "anschaffungskategorie"],
      required: true,
      type: "select",
      values: [{label: "", value: nil}, {label: "Werkstatt-Technik", value: "Werkstatt-Technik"}, {label: "Produktionstechnik", value: "Produktionstechnik"}, {label: "AV-Technik", value: "AV-Technik"}, {label: "Musikinstrumente", value: "Musikinstrumente"}, {label: "Facility Management", value: "Facility Management"}, {label: "IC-Technik/Software", value: "IC-Technik/Software"}],
      visibility_dependency_field_id: 15,
      visibility_dependency_value: "true",
      permissions: {role: :inventory_manager, owner: true},
      group: "Inventory"
    },{
      id: 16,
      label: "Owner",
      attribute: ["owner", "id"],
      type: "autocomplete",
      permissions: {role: :inventory_manager, owner: true},
      values: lambda{(InventoryPool.all.map {|x| {:value => x.id, :label => x.name}}).as_json},
      group: "Inventory"
    },{
      id: 17,
      label: "Last Checked",
      attribute: "last_check",
      permissions: {role: :lending_manager, owner: true},
      default: lambda{Date.today.as_json},
      type: "date",
      group: "Inventory",
      forPackage: true
    },{
      id: 18,
      label: "Responsible department",
      attribute: ["inventory_pool", "id"],
      type: "autocomplete",
      values: lambda{([{:value => nil, :label => _("None")}] + InventoryPool.all.map {|x| {:value => x.id, :label => x.name}}).as_json},
      permissions: {role: :inventory_manager, owner: true},
      group: "Inventory",
      forPackage: true
    },{
      id: 19,
      label: "Responsible person",
      attribute: "responsible",
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      group: "Inventory",
      forPackage: true
    },{
      id: 20,
      label: "User/Typical usage",
      attribute: "user_name",
      permissions: {role: :inventory_manager, owner: true},
      type: "text",
      group: "Inventory",
      forPackage: true
    },{
      id: 21,
      label: "Reference",
      attribute: ["properties", "reference"],
      permissions: {role: :inventory_manager, owner: true},
      required: true,
      values: [{label: "Running Account", value: "invoice"}, {label: "Investment", value: "investment"}],
      default: "invoice", 
      type: "radio",
      group: "Invoice Information"
    },{
      id: 22,
      label: "Project Number",
      attribute: ["properties", "project_number"],
      permissions: {role: :inventory_manager, owner: true},
      type: "text",
      required: true,
      visibility_dependency_field_id: 21,
      visibility_dependency_value: "investment",
      group: "Invoice Information"
    },{
      id: 23,
      label: "Invoice Number",
      attribute: "invoice_number",
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      group: "Invoice Information"
    },{
      id: 24,
      label: "Invoice Date",
      attribute: "invoice_date",
      permissions: {role: :lending_manager, owner: true},
      type: "date",
      group: "Invoice Information"
    },{
      id: 25,
      label: "Initial Price",
      attribute: "price",
      permissions: {role: :lending_manager, owner: true},
      type: "text",
      group: "Invoice Information",
      forPackage: true
    },{
      id: 27,
      label: "Supplier",
      attribute: ["supplier", "id"],
      type: "autocomplete",
      extensible: true,
      extended_key: ["supplier", "name"],
      permissions: {role: :lending_manager, owner: true},
      values: lambda{Supplier.order(:name).map {|x| {:value => x.id, :label => x.name}}.as_json},
      group: "Invoice Information"
    },{
      id: 28,
      label: "Warranty expiration",
      attribute: ["properties", "warranty_expiration"],
      permissions: {role: :lending_manager, owner: true},
      type: "date",
      group: "Invoice Information"
    },{
      id: 29,
      label: "Contract expiration",
      attribute: ["properties", "contract_expiration"],
      permissions: {role: :lending_manager, owner: true},
      type: "date",
      group: "Invoice Information"
    },{
      id: 30,
      label: "Umzug",
      attribute: ["properties", "umzug"],
      type: "select",
      values: [{label:"zügeln", value:"zügeln"}, {label:"sofort entsorgen", value:"sofort entsorgen"}, {label:"bei Umzug entsorgen", value:"bei Umzug entsorgen"}, {label:"bei Umzug verkaufen", value:"bei Umzug verkaufen"}],
      permissions: {role: :inventory_manager, owner: true},
      group: "Umzug"
    },{
      id: 31,
      label: "Zielraum",
      attribute: ["properties", "zielraum"],
      type: "text",
      permissions: {role: :inventory_manager, owner: true},
      group: "Umzug"
    },{
      id: 32,
      label: "Ankunftsdatum",
      attribute: ["properties", "ankunftsdatum"],
      type: "date",
      permissions: {role: :inventory_manager, owner: true},
      group: "Toni Ankunftskontrolle"
    },{
      id: 33,
      label: "Ankunftszustand",
      attribute: ["properties", "ankunftszustand"],
      type: "select",
      values: [{label:"intakt", value:"intakt"}, {label:"transportschaden", value:"transportschaden"}],
      permissions: {role: :inventory_manager, owner: true},
      group: "Toni Ankunftskontrolle"
    },{
      id: 34,
      label: "Ankunftsnotiz",
      attribute: ["properties", "ankunftsnotiz"],
      type: "textarea",
      permissions: {role: :inventory_manager, owner: true},
      group: "Toni Ankunftskontrolle"
    },{
      id: 35,
      label: "Model",
      attribute: ["model", "id"],
      value_label: ["model", "name"],
      form_name: "model_id",
      required: true,
      type: "autocomplete-search",
      search_path: lambda{|inventory_pool| Rails.application.routes.url_helpers.manage_models_path(inventory_pool, {all: true})},
      search_attr: "search_term",
      value_attr: "id",
      display_attr: "name",
      group: nil
    }
  ]

  def value(item)
    # NOTE OpenStruct is only used for serialized attributes
    Array(self.attribute).inject(item){|i,m| i.is_a?(Hash) ? OpenStruct.new(i).send(m) : i.send(m) }
  end

  def values
    if self[:values].is_a? Proc
      self[:values].call
    else
      self[:values]
    end
  end

  def default
    if self[:default].is_a? Proc
      self[:default].call
    else
      self[:default]
    end
  end

  def search_path(inventory_pool)
    if self[:search_path].is_a? Proc
      self[:search_path].call inventory_pool
    else
      self[:search_path]
    end
  end

  def as_json(options = {})
    h = self.attributes.clone
    h[:values] = values
    h[:default] = default
    h[:search_path] = search_path options[:current_inventory_pool]
    h.as_json options
  end

  def get_value_from_params(params)
    if self.attribute.is_a? Array
      begin
        self.attribute.inject(params) {|params,attr| 
          if params.is_a? Hash
            params[attr.to_sym]
          else
            params.send attr
          end
        }
      rescue
        nil
      end
    else
      params[self.attribute]
    end
  end

  def editable(user, inventory_pool, item)
    return true unless self.permissions

    return false if self[:permissions][:role] and not user.has_role? self[:permissions][:role], inventory_pool
    return false if self[:permissions][:owner] and item.owner != inventory_pool

    return true
  end

########

  def self.accessible_by user, inventory_pool
    Field.all.select do |field|
      if field[:permissions]
        user.has_role? field[:permissions][:role], inventory_pool
      else
        true
      end
    end
  end

end
