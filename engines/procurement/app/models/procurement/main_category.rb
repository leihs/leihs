module Procurement
  class MainCategory < ActiveRecord::Base

    has_many :budget_limits,
             dependent: :delete_all,
             inverse_of: :main_category
    accepts_nested_attributes_for :budget_limits,
                                  allow_destroy: true

    has_many :categories,
             dependent: :destroy,
             inverse_of: :main_category
    accepts_nested_attributes_for :categories,
                                  allow_destroy: true,
                                  reject_if: :all_blank

    has_many :requests,
             through: :categories,
             dependent: :restrict_with_exception

    has_attached_file :image,
                      styles: { normal: '40x40#' },
                      default_style: :normal
    validates_attachment_content_type :image, content_type: /.*/
    attr_accessor :image_delete
    before_validation { image.clear if image_delete == '1' }

    validates_presence_of :name
    validates_uniqueness_of :name

    def to_s
      name
    end

    default_scope { order(:name) }

    scope :with_categories, -> { joins(:categories).distinct }

    # override
    def can_destroy?
      requests.empty?
    end

  end
end
