class Partition < ActiveRecord::Base
  audited

  belongs_to :model, inverse_of: :partitions
  belongs_to :inventory_pool
  belongs_to :group, inverse_of: :partitions

  validates_presence_of :model, :inventory_pool, :group, :quantity
  validates_numericality_of :quantity, only_integer: true, greater_than: 0
  validates_uniqueness_of :group_id, scope: [:model_id, :inventory_pool_id]

  scope :with_generals, lambda {|model_ids: nil, inventory_pool_id: nil|
    find_by_sql query(model_ids: model_ids,
                      inventory_pool_id: inventory_pool_id)
  }

  # returns a hash as {group_id => quantity}
  # like {nil => 10, 41 => 3, 42 => 6, ...}
  def self.hash_with_generals(inventory_pool, model, groups = nil)
    a = with_generals(model_ids: [model.id], inventory_pool_id: inventory_pool.id)
    if groups
      group_ids = groups.map { |x| x.try(:id) }
      a = a.select { |p| group_ids.include? p.group_id }
    end
    h = Hash[a.map { |p| [p.group_id, p.quantity] }]
    h = { Group::GENERAL_GROUP_ID => 0 } if h.empty?
    h
  end

  def self.query(model_ids: nil, inventory_pool_id: nil)
    sql = 'SELECT model_id, inventory_pool_id, group_id, quantity ' \
              'FROM partitions WHERE 1=1 '
    sql += "AND model_id IN (#{model_ids.join(',')})  " if model_ids
    sql += "AND inventory_pool_id = #{inventory_pool_id} " if inventory_pool_id

    sql += 'UNION ' \
        'SELECT model_id, inventory_pool_id, NULL as group_id, ' \
        '(COUNT(i.id) - IFNULL((SELECT SUM(quantity) FROM partitions AS p ' \
          'WHERE p.model_id = i.model_id ' \
          'AND p.inventory_pool_id = i.inventory_pool_id '\
        'GROUP BY p.inventory_pool_id, p.model_id), 0)) as quantity ' \
        'FROM items AS i ' \
        'WHERE i.retired IS NULL AND i.is_borrowable = 1 AND i.parent_id IS NULL '
    sql += "AND i.model_id IN (#{model_ids.join(',')}) " if model_ids
    sql += "AND i.inventory_pool_id = #{inventory_pool_id} " if inventory_pool_id
    sql += 'GROUP BY i.inventory_pool_id, i.model_id'

    sql
  end
end
