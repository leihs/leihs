class AddVerificationFlagToGroups < ActiveRecord::Migration

  def change

    change_table :groups do |t|
      t.boolean :is_verification_required, default: false
      t.index   :is_verification_required
    end

  end

end
