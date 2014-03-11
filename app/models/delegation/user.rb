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
      has_and_belongs_to_many :delegated_users,
                              class_name: 'User',
                              join_table: 'delegations_users',
                              foreign_key: 'delegation_id',
                              association_foreign_key: 'user_id'

      scope :as_delegations, where(arel_table[:delegator_user_id].not_eq(nil))
      scope :not_as_delegations, where(delegator_user_id: nil)

      before_validation do
        if is_delegation
          delegated_users << delegator_user unless delegated_users.include? delegator_user
        end
      end

      validate do
        if is_delegation
          errors.add(:base, _("The responsible user has to be member of the delegation")) unless delegated_users.include? delegator_user
        end
      end

    end
  end

  def is_delegation
    not delegator_user_id.nil?
  end

end
