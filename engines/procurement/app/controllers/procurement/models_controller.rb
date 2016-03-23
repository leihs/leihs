require_dependency 'procurement/application_controller'

module Procurement
  class ModelsController < ApplicationController

    def index
      respond_to do |format|
        params[:paginate] = 'false'
        format.json do
          render json: Model.filter(params).to_json(only: :id, methods: :name)
        end
      end
    end

  end
end
