class DropRolesAndAccessLevels < ActiveRecord::Migration
  def change

    # create new enum with null allow
    execute "ALTER TABLE access_rights ADD COLUMN role ENUM('#{AccessRight::AVAILABLE_ROLES.join("', '")}')"

    # migrate data
    manager_access_rights = AccessRight.joins("INNER JOIN roles ON roles.id = access_rights.role_id").where(roles: {name: :manager})
    manager_access_rights.where(access_level: 3).update_all(role: AccessRight::ROLES_HIERARCHY.fetch(3))
    manager_access_rights.where(access_level: [1,2]).update_all(role: AccessRight::ROLES_HIERARCHY.fetch(2))

    customer_access_rights = AccessRight.joins("INNER JOIN roles ON roles.id = access_rights.role_id").where(roles: {name: :customer})
    customer_access_rights.update_all(role: :customer)

    admin_access_rights = AccessRight.joins("INNER JOIN roles ON roles.id = access_rights.role_id").where(roles: {name: :admin})
    admin_access_rights.update_all(role: :admin)

    # change enum to null not allowed
    execute "ALTER TABLE access_rights MODIFY role ENUM('#{AccessRight::AVAILABLE_ROLES.join("', '")}') NOT NULL"
    # also change another enum to null not allowed (forgotten on previous migrations)
    execute "ALTER TABLE contracts MODIFY status ENUM('#{Contract::STATUSES.join("', '")}') NOT NULL"

    change_table :access_rights do |t|
      t.remove :role_id
      t.remove :access_level
      t.index :role
    end
    AccessRight.reset_column_information

    drop_table :roles

  end
end
