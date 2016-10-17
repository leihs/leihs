require_dependency 'procurement/application_controller'

module Procurement
  class SettingsController < ApplicationController

    before_action do
      authorize Procurement::Setting
    end

    def edit
      @settings = Procurement::Setting.all_as_hash
    end

    def create
      errors = create_or_update

      if errors.empty?
        flash[:success] = _('Saved')
        head status: :ok
      else
        render json: errors, status: :internal_server_error
      end
    end

    private

    def create_or_update
      params.require(:settings).map do |param|
        permitted = param.permit(:key, :value)
        setting = Procurement::Setting.find_or_initialize_by(key: permitted[:key])
        setting.update_attributes(value: permitted[:value])
        setting.errors.full_messages
      end.flatten.compact
    end
  end
end
