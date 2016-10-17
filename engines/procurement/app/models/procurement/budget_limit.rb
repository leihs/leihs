module Procurement
  class BudgetLimit < ActiveRecord::Base

    belongs_to :budget_period
    belongs_to :main_category

    validates_presence_of :budget_period, :main_category, :amount
    validates_uniqueness_of :budget_period_id, scope: :main_category_id

    monetize :amount_cents

  end
end
