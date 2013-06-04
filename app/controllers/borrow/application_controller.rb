class Borrow::ApplicationController < ApplicationController

  layout "borrow"

  before_filter do
    require_role "customer"
  end

  def start
    @categories = (current_user.all_categories & Category.roots).sort
  end

end
