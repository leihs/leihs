require_dependency 'procurement/application_controller'

module Procurement
  class TemplatesController < ApplicationController
    def self.policy_class
      CategoryPolicy
    end

    def index
      @categories = Procurement::Category.all.select do |category|
        category.inspectable_by?(current_user)
      end
    end

    def create
      errors = create_or_update_or_destroy

      if errors.empty?
        flash[:success] = _('Saved')
        head status: :ok
      else
        render json: errors, status: :internal_server_error
      end
    end

    private

    def create_or_update_or_destroy
      errors = []

      params.require(:categories).each_pair do |id, param|
        category = Procurement::Category.find(id)
        authorize category, :inspectable_by_user?

        category.update_attributes(templates_attributes: \
                                   param[:templates_attributes])

        errors << category.errors.full_messages
      end

      errors.flatten.compact
    end

  end
end
