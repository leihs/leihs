require_dependency 'procurement/application_controller'

module Procurement
  class SuppliersController < ApplicationController

    def index
      respond_to do |format|
        format.json do
          render json: Supplier.filter(params).to_json(only: [:id, :name])
        end
      end
    end

  end
end
