# -*- encoding : utf-8 -*-

class Field < ActiveRecord::Base
  audited

  serialize :data, JSON

  ####################################

  GROUPS_ORDER = [nil,
                  'General Information',
                  'Status',
                  'Location',
                  'Inventory',
                  'Invoice Information',
                  'Umzug',
                  'Toni Ankunftskontrolle',
                  'Maintenance']

  default_scope { where(active: true).order(:position) }

  ####################################

  def value(item)
    Array(data['attribute']).inject(item) do |r, m|
      if r.is_a?(Hash)
        r[m]
      else
        if m == 'id'
          r
        else
          r.try(:send, m)
        end
      end
    end
  end

  def set_default_value(item)
    return unless data.key?('default')
    return unless value(item).nil?

    attrs = Array(data['attribute'])
    attrs.inject(item) do |r, m|
      if m == attrs[-1]
        if r.is_a?(Hash)
          r[m] = default
        else
          r.send "#{m}=", default
        end
      else
        if r.is_a?(Hash)
          r[m]
        else
          r.send m
        end
      end
    end
  end

  def values
    case data['values']
    when 'all_inventory_pools'
      (InventoryPool.all.map { |x| { value: x.id, label: x.name } }).as_json
    when 'all_buildings'
      ([{ value: nil, label: _('None') }] \
       + Building.all.map { |x| { value: x.id, label: x.to_s } }).as_json
    when 'all_suppliers'
      Supplier.order(:name).map { |x| { value: x.id, label: x.name } }.as_json
    when 'all_currencies'
      Money::Currency
        .all
        .map(&:iso_code)
        .sort
        .map { |iso_code| { label: iso_code, value: iso_code } }
    else
      data['values']
    end
  end

  def default
    case data['default']
    when 'today'
      Time.zone.today.as_json
    else
      data['default']
    end
  end

  def search_path(inventory_pool)
    case data['search_path']
    when 'models'
      Rails
        .application
        .routes
        .url_helpers
        .manage_models_path(inventory_pool, all: true)
    when 'software'
      Rails
        .application
        .routes
        .url_helpers
        .manage_models_path(inventory_pool, all: true, type: :software)
    else
      data['search_path']
    end
  end

  def as_json(options = {})
    h = data.clone
    h[:id] = id
    h[:values] = values
    h[:default] = default
    h[:search_path] = search_path options[:current_inventory_pool]
    h[:hidden] = true if options[:hidden_field_ids].try :include?, id.to_s
    h.as_json options
  end

  def get_value_from_params(params)
    if data['attribute'].is_a? Array
      begin
        data['attribute'].inject(params) do|params, attr|
          if params.is_a? Hash
            params[attr.to_sym]
          else
            params.send attr
          end
        end
      rescue
        nil
      end
    else
      params[data['attribute']]
    end
  end

  def editable(user, inventory_pool, item)
    return true unless data['permissions']

    if data['permissions']['role'] \
      and not user.has_role? data['permissions']['role'], inventory_pool
      return false
    end
    if data['permissions']['owner'] and item.owner != inventory_pool
      return false
    end

    true
  end

  ########

  def accessible_by?(user, inventory_pool)
    if data['permissions']
      user.has_role? data['permissions']['role'], inventory_pool
    else
      true
    end
  end

end
