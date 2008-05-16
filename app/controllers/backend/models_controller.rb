class Backend::ModelsController < Backend::BackendController

  def index
    @models = Model.find(:all)    
  end


  def show
    @model = Model.find(params[:id])
 
    render :layout => $modal_layout_path
  end
  
end
