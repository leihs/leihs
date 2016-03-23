require_dependency 'procurement/application_controller'

module Procurement
  class LocationsController < ApplicationController

    def index
      respond_to do |format|
        format.json do
          render json: Location.search(params[:search_term]) \
                        .to_json(only: :id, methods: :to_s)
        end
      end
    end

  end
end
