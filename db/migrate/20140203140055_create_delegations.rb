class CreateDelegations < ActiveRecord::Migration
  def change

    change_table :users do |t|
      t.belongs_to :delegation_responsible_user
    end

    create_table :delegations_users, :id => false do |t|
      t.belongs_to :delegation
      t.belongs_to :user
    end
    change_table :delegations_users do |t|
      t.index [:user_id, :delegation_id], :unique => true
      t.index :delegation_id
    end

  end
end
