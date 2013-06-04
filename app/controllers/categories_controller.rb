class CategoriesController < ApplicationController

  def index
    @categories = if params[:children]
      if params[:category_id]
        Category.find(params[:category_id]).children
      elsif params[:category_ids]
        Category.find(params[:category_ids]).map(&:children)
      end
    else
      Category.all
    end
  end

  def image
    category = Category.find params[:id]
    redirect_to category.image, :status => :moved_permanently
  end

end
  
