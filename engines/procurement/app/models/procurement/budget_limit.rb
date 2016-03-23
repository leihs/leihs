module Procurement
  class BudgetLimit < ActiveRecord::Base

    belongs_to :budget_period
    belongs_to :group

    validates_presence_of :budget_period, :group, :amount
    validates_uniqueness_of :budget_period_id, scope: :group_id

    monetize :amount_cents

  end
end
