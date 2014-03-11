class CreateDelegations < ActiveRecord::Migration
  def change

    change_table :users do |t|
      t.belongs_to :delegator_user
    end

    create_table :delegations_users, :id => false do |t|
      t.belongs_to :delegation
      t.belongs_to :user
    end
    change_table :delegations_users do |t|
      t.index [:user_id, :delegation_id], :unique => true
      t.index :delegation_id
    end

    change_table :contracts do |t|
      t.belongs_to :delegated_user
    end

  end
end
