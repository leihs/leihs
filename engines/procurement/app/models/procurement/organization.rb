module Procurement
  class Organization < ActiveRecord::Base
    extend ActsAsTree::TreeWalker

    acts_as_tree # order: "name"

    has_many :accesses
    has_many :requests

    validates_presence_of :name

    belongs_to :parent, class_name: 'Organization'
    has_many :children, class_name: 'Organization', foreign_key: :parent_id

    scope :departments, -> { where(parent_id: nil) }

    default_scope { order(:name) }

    def to_s
      name
    end

    def name_with_parent
      s = ''
      if parent
        s += parent.name
        s += ', '
      end
      s += name
      s
    end

    def self.cleanup
      where.not(parent_id: nil).each do |organization|
        if organization.accesses.empty? and organization.requests.empty?
          organization.destroy
        end
      end

      departments.each do |department|
        if department.children.empty?
          department.destroy
        end
      end
    end

  end
end
