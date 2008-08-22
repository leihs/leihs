class Admin::ModelsController < Admin::AdminController
  active_scaffold :model do |config|
    config.columns = [:manufacturer, :name, :model_groups, :locations, :compatibles]
    config.columns.each { |c| c.collapsed = true }

  end


  
##########################################################

## TODO
#  def upload_image
#    @model = current_inventory_pool.models.find(params[:id])
#
#    if request.post?
#      @image = Image.new(params[:image])
#      @image.model = @model
#      if @image.save
#        flash[:notice] = 'Attachment was successfully created.'
#        redirect_to :action => 'details', :id => @model.id
#      end
#    end
#  end
  
end
