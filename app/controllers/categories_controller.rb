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
    if category.image.nil?
      render :status => :not_found, :nothing => true
    else
      redirect_to category.image, :status => :moved_permanently
    end
  end

end
  
