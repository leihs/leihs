class FrontendController < ApplicationController

  require_role "customer"

  layout "frontend"

  def search
    models = Model.search2(params[:term]).filter2(:inventory_pool_id => current_user.inventory_pool_ids).limit(5)

    results = models.map do |model|
      { label: model.to_s,
        type: "model",
        image: model.image_thumb,
        link: model_path(model) }
    end

    ids = current_user.all_categories.map(&:id)
    categories = Category.search2(params[:term]).where(:id => ids).limit(5)

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
