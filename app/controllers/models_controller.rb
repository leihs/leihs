class ModelsController < FrontendController
  
  before_filter :pre_load

  def index
             
    model_group = if params[:category_id]
      @category = Category.includes(:children).find(params[:category_id])
    elsif params[:template_id]
      @template = Template.includes(:children).find(params[:template_id])
    else
      # models index is always nested either to a category or to a template
      # TODO raise exception
    end

    @children = model_group.children

    #1402 TODO refactor to User#accessible_models
    models = model_group.all_models.
                      joins(:items, :partitions).
                      includes(:properties, :images). #not working# :inventory_pools
                      where(["items.inventory_pool_id IN (:ip_ids)
                              AND (partitions.group_id IN (:groups_ids)
                                   OR (partitions.group_id IS NULL AND partitions.inventory_pool_id IN (:ip_ids)))",
                              {:ip_ids => current_user.active_inventory_pool_ids,
                               :groups_ids => current_user.group_ids} ])

    @models_attributes = models.as_json(:methods => :image_thumb, :include => :properties, :with => {:user => current_user })

    respond_to do |format|
      format.html { }
      format.js { render :json => @model }
    end
  end  

#######################################################  
  
  def show
    respond_to do |format|
      format.html
    end
  end

#################################################################

  def chart
    render :layout => false
  end

#################################################################

  def book
    @availability = @model.availability_periods_for_user(current_user, true).collect do |av|
      option_name = "#{av[:inventory_pool][:name]}"
      [option_name, av[:inventory_pool][:id], {:"data-total_borrowable"   => av[:total_borrowable],
                                               :"data-closed_days"        => av[:inventory_pool][:closed_days],
                                               :"data-name"               => av[:inventory_pool][:name],
                                               :"data-address"            => av[:inventory_pool][:address],
                                               :"data-availability_dates" => av[:availability].to_json}]
    end
  end

#################################################################

  private
  
  def pre_load
    params[:model_id] ||= params[:id] if params[:id]
    @model = current_user.models.find(params[:model_id]) if params[:model_id]
    @inventory_pool = current_user.inventory_pools.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
  end


end
