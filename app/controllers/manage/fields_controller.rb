class Manage::FieldsController < Manage::ApplicationController
    
  def index
    @fields = Field.accessible_by current_user, current_inventory_pool
  end  

end
