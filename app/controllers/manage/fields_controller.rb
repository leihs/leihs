class Manage::FieldsController < Manage::ApplicationController

  def index
    @fields = Field.all.select {|f| f.has_target_type?(params[:target_type]) and f.accessible_by?(current_user, current_inventory_pool) }
  end

end
