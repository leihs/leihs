class ForeignKeys < ActiveRecord::Migration
  def change

    begin

      add_foreign_key(:access_rights, :inventory_pools, dependent: :delete)
      add_foreign_key(:access_rights, :users)
      add_foreign_key(:accessories, :models, dependent: :delete)
      add_foreign_key(:attachments, :models, dependent: :delete)
      add_foreign_key(:contract_lines, :items)
      add_foreign_key(:contract_lines, :models)
      add_foreign_key(:contract_lines, :options)
      add_foreign_key(:contract_lines, :purposes)
      add_foreign_key(:contract_lines, :contracts, dependent: :delete)
      add_foreign_key(:contract_lines, :users, column: 'returned_to_user_id')
      add_foreign_key(:contracts, :inventory_pools)
      add_foreign_key(:contracts, :users)
      add_foreign_key(:contracts, :users, column: 'delegated_user_id')
      add_foreign_key(:contracts, :users, column: 'handed_over_by_user_id')
      add_foreign_key(:database_authentications, :users, dependent: :delete)
      add_foreign_key(:groups, :inventory_pools)
      add_foreign_key(:histories, :users)
      add_foreign_key(:holidays, :inventory_pools, dependent: :delete)
      add_foreign_key(:inventory_pools, :addresses)
      add_foreign_key(:items, :inventory_pools)
      add_foreign_key(:items, :inventory_pools, column: 'owner_id')
      add_foreign_key(:items, :items, column: 'parent_id', dependent: :nullify)
      add_foreign_key(:items, :locations)
      add_foreign_key(:items, :models)
      add_foreign_key(:items, :suppliers)
      add_foreign_key(:locations, :buildings)
      add_foreign_key(:model_group_links, :model_groups, column: 'ancestor_id', dependent: :delete)
      add_foreign_key(:model_group_links, :model_groups, column: 'descendant_id', dependent: :delete)
      add_foreign_key(:model_links, :model_groups, dependent: :delete)
      add_foreign_key(:model_links, :models, dependent: :delete)
      add_foreign_key(:notifications, :users, dependent: :delete)
      add_foreign_key(:options, :inventory_pools)
      add_foreign_key(:partitions, :groups)
      add_foreign_key(:partitions, :inventory_pools)
      add_foreign_key(:partitions, :models, dependent: :delete)
      add_foreign_key(:properties, :models, dependent: :delete)
      add_foreign_key(:users, :authentication_systems)
      add_foreign_key(:users, :languages)
      add_foreign_key(:users, :users, column: 'delegator_user_id')
      add_foreign_key(:workdays, :inventory_pools, dependent: :delete)

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
