class FrontendController < ApplicationController

  require_role "customer"

  layout "frontend"

  def search
    models = Model.search params[:term], {:star => true, :page => 1, :per_page => 5,
                                          :with => {:inventory_pool_id => current_user.inventory_pool_ids} }
    results = models.map do |model|
      { label: model.to_s,
        type: "model",
        image: model.image_thumb,
        link: model_path(model) }
    end

    categories = Category.search params[:term], {:star => true, :page => 1, :per_page => 5,
                                                 :with => {:sphinx_internal_id => current_user.all_categories.map(&:id) } }
                                                 # NOTE alternatives:
                                                 # :sphinx_internal_id => current_user.category_ids
                                                 # :inventory_pool_id => current_user.inventory_pool_ids
    results += categories.map do |category|
      { label: category.to_s,
        type: "category",
        link: category_models_path(category) }
    end

    respond_to do |format|
      format.js { render :json => results }
    end
  end
  
end
