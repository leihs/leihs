class DatabaseConstrains < ActiveRecord::Migration
  def up

    begin
      AccessRight.where(user_id: nil).delete_all
      AccessRight.where(role: nil).delete_all
      change_column_null :access_rights, :user_id, false
      change_column_null :access_rights, :role, false

      change_column_null :accessories, :name, false

      change_column_null :buildings, :name, false

      change_column_null :database_authentications, :login, false
      change_column_null :database_authentications, :user_id, false

      change_column_null :groups, :name, false
      change_column_null :groups, :inventory_pool_id, false

      InventoryPool.where(shortname: nil).update_all(shortname: '-') # TODO: fill in correct value
      InventoryPool.where(email: nil).update_all(email: '-') # TODO: fill in correct value
      change_column_null :inventory_pools, :name, false
      change_column_null :inventory_pools, :shortname, false
      change_column_null :inventory_pools, :email, false

      change_column_null :accessories, :name, false

      change_column_null :items, :inventory_code, false
      change_column_null :items, :model_id, false
      change_column_null :items, :owner_id, false
      change_column_null :items, :inventory_pool_id, false

      change_column_null :models, :product, false

      change_column_null :model_groups, :name, false

      ModelLink.where(model_group_id: nil).delete_all
      change_column_null :model_links, :model_group_id, false
      change_column_null :model_links, :model_id, false
      change_column_null :model_links, :quantity, false

      change_column_null :options, :inventory_pool_id, false
      change_column_null :options, :product, false

      change_column_null :partitions, :model_id, false
      change_column_null :partitions, :inventory_pool_id, false
      change_column_null :partitions, :group_id, false
      change_column_null :partitions, :quantity, false

      change_column_null :properties, :key, false
      change_column_null :properties, :value, false

      Reservation.where(user_id: nil).delete_all
      change_column_null :reservations, :user_id, false
      change_column_null :reservations, :inventory_pool_id, false
      change_column_null :reservations, :status, false

      change_column_null :settings, :local_currency_string, false
      change_column_null :settings, :email_signature, false
      change_column_null :settings, :default_email, false

      change_column_null :suppliers, :name, false

      User.where(firstname: nil).update_all(firstname: '-') # TODO: fill in correct value
      change_column_null :users, :firstname, false

    rescue
      puts %Q(
        *****************************************************************************************
        Error: the database has inconsistency issues caused by null columns.
        Please visit the report at the following url: admin/database/not_null_columns
        After solving the issues, run again: rake db:migrate
        *****************************************************************************************
      )

      raise
    end

  end
end
