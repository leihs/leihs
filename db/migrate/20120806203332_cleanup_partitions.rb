class CleanupPartitions < ActiveRecord::Migration
  def up

    Partition.unscoped.where(:group_id => nil).delete_all

    # redefining view without superfluous conditions
    execute("DROP VIEW IF EXISTS partitions_with_generals")
    execute("CREATE VIEW partitions_with_generals AS " \
                "SELECT model_id, inventory_pool_id, group_id, quantity " \
                "FROM partitions " \
              "UNION " \
                "SELECT model_id, inventory_pool_id, NULL as group_id, " \
                  "(COUNT(i.id) - IFNULL((SELECT SUM(quantity) FROM partitions AS p " \
                      "WHERE p.model_id = i.model_id AND p.inventory_pool_id = i.inventory_pool_id " \
                      "GROUP BY p.inventory_pool_id, p.model_id), 0)) as quantity " \
                "FROM items AS i WHERE i.retired IS NULL AND i.is_borrowable = 1 AND i.parent_id IS NULL " \
                "GROUP BY i.inventory_pool_id, i.model_id;")

  end

  def down
  end
end
