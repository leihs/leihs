class Borrow::CategoriesController < Borrow::ApplicationController

  def index(category_id = params[:category_id])
    categories = (current_user.all_categories & Category.find(category_id).children).sort

    output = categories.map do |category|
      {id: category.id,
       name: category.label(category_id) }
    end

    render json: output
  end

end
  
