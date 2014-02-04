module Delegation::User

  def self.included(base)
    base.class_eval do

      belongs_to :delegator_user, class_name: 'User'

      # NOTE this method is called from a normal user perspective
      has_and_belongs_to_many :delegations,
                              class_name: 'User',
                              join_table: 'delegations_users',
                              foreign_key: 'user_id',
                              association_foreign_key: 'delegation_id'

      # NOTE this method is called from a delegation perspective
      has_and_belongs_to_many :users,
                              class_name: 'User',
                              join_table: 'delegations_users',
                              foreign_key: 'delegation_id',
                              association_foreign_key: 'user_id'

      scope :as_delegations, where("delegator_user_id IS NOT NULL")
      scope :not_as_delegations, where(delegator_user_id: nil)

      validate do
        if is_delegation
          errors.add(:base, _("The responsible user has to be member of the delegation")) unless users.exists? delegator_user
        end
      end

    end
  end

  def is_delegation
    self.class.as_delegations.exists? self
  end

end