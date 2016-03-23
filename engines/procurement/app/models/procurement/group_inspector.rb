module Procurement
  class GroupInspector < ActiveRecord::Base

    validates_presence_of :user, :group
    validates_uniqueness_of :user_id, scope: :group_id

    belongs_to :user
    belongs_to :group

  end
end
