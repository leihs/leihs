class Admin::ModelsController < Admin::AdminController

  before_filter :pre_load

  active_scaffold :model do |config|
    config.columns = [:name, :manufacturer, :model_groups, :locations, :compatibles]
    config.columns.each { |c| c.collapsed = true }

  end


#################################################################

  def index
    unless params[:query].blank?
      # TODO *16* fix total_hits, now is wrong summing model(s).items.size
      @models = Model.find_by_contents("*" + params[:query] + "*", :page => params[:page], :per_page => $per_page)
    else
          
      @models = Model.paginate :page => params[:page], :per_page => $per_page
    end
  end

  def show
    # template has to be .rhtml (??)
  end

  def new
    render :action => 'show'
  end
      
  def update
    @model ||= Model.create
    @model.name = params[:name]
    @model.manufacturer = params[:manufacturer]
    @model.save
    render :action => 'show'
  end

#################################################################

  def items
    #render :layout => false
  end

#################################################################

  def properties
    #render :layout => false
  end
  
  def add_property
    @model.properties << Property.create(:key => params[:key], :value => params[:value])
    redirect_to :action => 'properties', :id => @model
  end

  def remove_property
    @model.properties.delete(@model.properties.find(params[:property_id]))
    redirect_to :action => 'properties', :id => @model
  end

#################################################################

  def accessories
    #render :layout => false
  end
  
  def add_accessory
    @model.accessories << Accessory.create(:name => params[:name])
    redirect_to :action => 'accessories', :id => @model
  end

  def remove_accessory
    @model.accessories.delete(@model.accessories.find(params[:accessory_id]))
    redirect_to :action => 'accessories', :id => @model
  end
  

#################################################################

  def images
    if request.post?
      @image = Image.new(params[:image])
      @image.model = @model
      if @image.save
        flash[:notice] = 'Attachment was successfully created.'
      else
        flash[:notice] = 'Upload error.'
      end
    end
  end

#################################################################

  private
  
  def pre_load
    params[:id] ||= params[:model_id] if params[:model_id]
    @model = Model.find(params[:id]) if params[:id]
    @model ||= Model.new
  end
  
  
end
