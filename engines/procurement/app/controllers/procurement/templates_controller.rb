require_dependency 'procurement/application_controller'

module Procurement
  class TemplatesController < ApplicationController
    def self.policy_class
      GroupPolicy
    end

    before_action do
      @group = Procurement::Group.find(params[:group_id])
      authorize @group, :inspectable_by_user?
    end

    def index
      @template_categories = @group.template_categories
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
      params.require(:template_categories).values.map do |param|
        if param[:id]
          r = @group.template_categories.find(param[:id])
          if param.delete(:_destroy) == '1' or (param[:name].blank? \
            and param[:templates_attributes].flat_map(&:values).all?(&:blank?))
            r.destroy
          else
            r.update_attributes(param)
          end
        else
          next if param[:name].blank? \
            and param[:templates_attributes].flat_map(&:values).all?(&:blank?)
          r = @group.template_categories.create(param)
        end
        r.errors.full_messages
      end.flatten.compact
    end

  end
end
