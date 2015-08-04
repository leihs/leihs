class ForeignKeys < ActiveRecord::Migration
  def change

    begin

      add_foreign_key(:access_rights, :inventory_pools, on_delete: :cascade)
      add_foreign_key(:access_rights, :users)
      add_foreign_key(:accessories, :models, on_delete: :cascade)
      add_foreign_key(:attachments, :models, on_delete: :cascade)
      add_foreign_key(:contract_lines, :items)
      add_foreign_key(:contract_lines, :models)
      add_foreign_key(:contract_lines, :options)
      add_foreign_key(:contract_lines, :purposes)
      add_foreign_key(:contract_lines, :contracts, on_delete: :cascade)
      add_foreign_key(:contract_lines, :users, column: 'returned_to_user_id')
      add_foreign_key(:contracts, :inventory_pools)
      add_foreign_key(:contracts, :users)
      add_foreign_key(:contracts, :users, column: 'delegated_user_id')
      add_foreign_key(:contracts, :users, column: 'handed_over_by_user_id')
      add_foreign_key(:database_authentications, :users, on_delete: :cascade)
      add_foreign_key(:groups, :inventory_pools)
      add_foreign_key(:histories, :users)
      add_foreign_key(:holidays, :inventory_pools, on_delete: :cascade)
      add_foreign_key(:inventory_pools, :addresses)
      add_foreign_key(:items, :inventory_pools)
      add_foreign_key(:items, :inventory_pools, column: 'owner_id')
      add_foreign_key(:items, :items, column: 'parent_id', on_delete: :nullify)
      add_foreign_key(:items, :locations)
      add_foreign_key(:items, :models)
      add_foreign_key(:items, :suppliers)
      add_foreign_key(:locations, :buildings)
      add_foreign_key(:model_group_links, :model_groups, column: 'ancestor_id', on_delete: :cascade)
      add_foreign_key(:model_group_links, :model_groups, column: 'descendant_id', on_delete: :cascade)
      add_foreign_key(:model_links, :model_groups, on_delete: :cascade)
      add_foreign_key(:model_links, :models, on_delete: :cascade)
      add_foreign_key(:notifications, :users, on_delete: :cascade)
      add_foreign_key(:options, :inventory_pools)
      add_foreign_key(:partitions, :groups)
      add_foreign_key(:partitions, :inventory_pools)
      add_foreign_key(:partitions, :models, on_delete: :cascade)
      add_foreign_key(:properties, :models, on_delete: :cascade)
      add_foreign_key(:users, :authentication_systems)
      add_foreign_key(:users, :languages)
      add_foreign_key(:users, :users, column: 'delegator_user_id')
      add_foreign_key(:workdays, :inventory_pools, on_delete: :cascade)

      # join tables
      add_foreign_key(:accessories_inventory_pools, :accessories)
      add_foreign_key(:accessories_inventory_pools, :inventory_pools)
      add_foreign_key(:delegations_users, :users)
      add_foreign_key(:delegations_users, :users, column: 'delegation_id')
      add_foreign_key(:groups_users, :groups)
      add_foreign_key(:groups_users, :users)
      add_foreign_key(:inventory_pools_model_groups, :inventory_pools)
      add_foreign_key(:inventory_pools_model_groups, :model_groups)
      add_foreign_key(:models_compatibles, :models)
      add_foreign_key(:models_compatibles, :models, column: 'compatible_id')

    rescue

      puts %Q(
        *************************************************************************************
        Error: the database has inconsistency issues caused by dead references.
        Please visit the consistency report at the following url: /admin/database/consistency
        After solving the issues, run again: rake db:migrate
        *************************************************************************************
      )

      raise

    end

  end
end
