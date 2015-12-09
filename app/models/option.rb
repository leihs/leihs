# encoding: utf-8
# Options are things that can be borrowed. The are listed
# within #OptionLines which can be added to a #Contract.
# Options don't have their own barcode and thus don't have
# individual identities (contrary to #Item s) and thus can
# be given out by the #InventoryPool manager in arbitrary
# quantities. Also Options are not an instance of some
# #Model as id the case for #Item s.
#
class Option < ActiveRecord::Base
  include DefaultPagination
  audited

  belongs_to :inventory_pool

  has_many :option_lines, dependent: :restrict_with_exception

  validates_presence_of :inventory_pool, :product
  validates_uniqueness_of(:inventory_code,
                          scope: :inventory_pool_id,
                          unless: proc { |record| record.inventory_code.blank? })

  before_validation do |record|
    if !record.inventory_code.nil? and record.inventory_code.blank?
      record.inventory_code = nil
    end
  end

  ##########################################

  SEARCHABLE_FIELDS = %w(manufacturer product version inventory_code)

  scope :search, lambda { |query, fields = []|
    sql = all
    return sql if query.blank?

    query.split.each do|q|
      q = "%#{q}%"
      # FIXME: use fields with SEARCHABLE_FIELDS
      sql = sql.where(arel_table[:manufacturer].matches(q)
                      .or(arel_table[:product].matches(q))
                      .or(arel_table[:version].matches(q))
                      .or(arel_table[:inventory_code].matches(q)))
    end
    sql
  }

  def self.filter(params, inventory_pool = nil)
    options = inventory_pool ? inventory_pool.options : all
    unless params[:search_term].blank?
      options = options.search(params[:search_term],
                               [:manufacturer, :product, :versin])
    end
    options = options.where(id: params[:ids]) if params[:ids]
    if params[:sort] and params[:order]
      options = options.order("#{params[:sort]} #{params[:order]}")
    end
    options = options.default_paginate params unless params[:paginate] == 'false'
    options
  end

  ##########################################

  # TODO: 2702** before_destroy: check if option_lines.empty?

  def needs_permission?
    false
  end

  def to_s
    "#{name}"
  end

  def name
    [product, version].compact.join(' ')
  end

  # NOTE when we call option_line.item.model, item is actually an option,
  # then model it's itself again
  def model
    self
  end

  # Generates an array suitable for outputting a line of CSV using CSV
  def to_csv_array
    # Using #{} notation to catch nils gracefully and silently
    {
      model_name: "#{self.name}",
      _('Inventory Code') => "#{self.inventory_code}",
      _('Responsible department') => "#{self.inventory_pool.try(:name)}",
      _('Categories') => "#{_('Option')}",
      _('Initial Price') => "#{self.price}"
    }
  end

end
