module DefaultPagination
  extend ActiveSupport::Concern

  module Collection
    def default_paginate(params, **options)
      page = params[:page] || 1
      per_page = [
        params[:per_page].try(&:to_i) || 20,
        100
      ].min

      paginate page: page, per_page: per_page, **options
    end
  end

  included do
    extend Collection
  end

end
