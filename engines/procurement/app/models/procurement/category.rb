module Procurement
  class Category < ActiveRecord::Base

    has_many :category_inspectors, dependent: :delete_all
    has_many :inspectors, -> { order('firstname, lastname') },
             through: :category_inspectors,
             source: :user
    has_many :requests, dependent: :restrict_with_exception

    has_many :templates, -> { order(:article_name) }, dependent: :delete_all
    accepts_nested_attributes_for :templates,
                                  allow_destroy: true,
                                  reject_if: :all_blank

    belongs_to :main_category

    validates_presence_of :name, :main_category
    validates_uniqueness_of :name

    def to_s
      main_category.name + ' > ' + name
    end

    default_scope { order(:name) }

    scope :inspectable_by, lambda {|user|
      joins(:category_inspectors) \
        .where(procurement_category_inspectors: { user_id: user })
    }

    # NOTE: not used but ready if needed #
    # scope :search, lambda { |query|
    #   sql = all
    #   return sql if query.blank?
    #
    #   query.split.each do |q|
    #     next if q.blank?
    #     q = "%#{q}%"
    #     sql = sql.where(arel_table[:name].matches(q)
    #                     .or(Procurement::MainCategory
    #                         .arel_table[:name].matches(q))
    #                     .or(Procurement::Template
    #                         .arel_table[:article_name].matches(q))
    #                    )
    #   end
    #   sql.joins('LEFT JOIN procurement_main_categories ON ' \
    #             'procurement_main_categories.id = ' \
    #             'procurement_categories.main_category_id')
    #       .joins('LEFT JOIN procurement_templates ON ' \
    #              'procurement_categories.id = procurement_templates.category_id')
    # }

    def inspector_ids_with_split=(val)
      self.inspector_ids_without_split = val.split(',').map &:to_i
    end
    alias_method_chain :inspector_ids=, :split

    ########################################################

    def inspectable_by?(user)
      category_inspectors.where(user_id: user).exists?
    end

    class << self
      def inspector_of_any_category?(user)
        Procurement::CategoryInspector.where(user_id: user).exists?
      end
    end

  end
end
