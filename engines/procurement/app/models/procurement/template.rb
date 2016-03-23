module Procurement
  class Template < ActiveRecord::Base

    belongs_to :template_category
    belongs_to :model     # from parent application
    belongs_to :supplier  # from parent application
    has_many :requests, dependent: :nullify

    monetize :price_cents, allow_nil: true

    # NOTE not executing on unchanged existing records
    before_validation on: [:create, :update] do
      self.price ||= 0
    end

    before_save on: :update do
      if article_name_changed? and \
        (article_number.blank? or article_number_changed?)
        requests.update_all(template_id: nil)
      end
    end

    validates_presence_of :article_name

    def to_s
      article_name
    end

  end
end
