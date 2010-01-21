class ModelsController < FrontendController

  before_filter :pre_load

  def index( category_id = params[:category_id].to_i, # TODO 18** nested route ?
             start = (params[:start] || 0).to_i,
             limit = (params[:limit] || 25).to_i,
             query = params[:query],
             recent = params[:recent],
             sort = params[:sort] || 'name', # OPTIMIZE 0501
             sort_mode = params[:dir] || 'ASC' ) # OPTIMIZE 0501
    
    sort_mode = sort_mode.downcase.to_sym # OPTIMIZE 0501
      
    # OPTIMIZE 21** conditions. avoid +&+ intersections because are breaking paginator, forcing to use Array instead of ActiveRecord
    conditions = ["1"] 
    
    if recent
      models = current_user.orders.sort.collect(&:models).flatten.uniq[start,limit]
      models ||= []
    else
      models = current_user.models
      conditions.first << " AND inventory_pools.id IN (?) AND items.is_borrowable = 1 AND items.parent_id IS NULL AND access_rights.level >= items.required_level"
      conditions << current_inventory_pools 
    end

    # OPTIMIZE 0907
    if category_id > 0
      category = Category.find(category_id)
      m_ids= (category.children.recursive.to_a << category).collect(&:models).flatten.uniq.collect(&:id)
      conditions.first << " AND models.id IN (?)"
      conditions << m_ids 
    end

    # TODO 09** merge paginate to search
    unless query.blank?
      # TODO 18** include Templates: models += current_user.templates
      models = models.all(:conditions => conditions)
      
      @models = models.search query, { :star => true,
                                       :offset => start, :limit => limit,
                                      # TODO 0501 { :page => params[:page],
                                      #             :per_page => $per_page,
                                       :order => sort, :sort_mode => sort_mode }
    else
      @models = models.paginate :page => ((start / limit) + 1), :per_page => limit, :order => sanitize_order(sort, sort_mode), :conditions => conditions
          # OPTIMIZE N+1 select problem, :include => :locations
    end
    c = @models.total_entries

    respond_to do |format|
      format.ext_json { render :json => @models.to_ext_json(:class => "Model",
                                                            :count => c,
                                                            :methods => :image_thumb,
                                                            :except => [ :internal_description,
                                                                         :info_url,
                                                                         :maintenance_period,
                                                                         :created_at,
                                                                         :updated_at ],
                                                            :include => {
                                                                :inventory_pools => { :records => current_inventory_pools,
                                                                                      :except => [:description,
                                                                                                  :logo_url,
                                                                                                  :contract_url,
                                                                                                  :contract_description,
                                                                                                  :created_at,
                                                                                                  :updated_at] } }
                                                                 ) }
    end
  end  

#######################################################  
  
  def show
    @models = [@model]
    c = @models.size
    respond_to do |format|
      format.ext_json { render :json => @models.to_ext_json(:class => "Model",
                                                            :count => c,
                                                            :methods => [:needs_permission, :package_models],
                                                            :except => [ :internal_description,
                                                                         :info_url,
                                                                         :maintenance_period,
                                                                         :created_at,
                                                                         :updated_at ],
                                                            :include => {
                                                                :properties => { :except => [:created_at,
                                                                                             :updated_at] },
                                                                :accessories => { :except => [:model_id] },
                                                                :compatibles => { :records => current_inventory_pools.collect(&:models).flatten.uniq,
                                                                                  :except => [:created_at,
                                                                                             :updated_at,
                                                                                             :model_id,
                                                                                             :compatible_id] },
                                                                :inventory_pools => { :records => current_inventory_pools,
                                                                                      :methods => [[:items_size, @model.id]],
                                                                                      :only => [:id, :name] },
                                                                :images => { :methods => [:public_filename, :public_filename_thumb],
                                                                             :except => [:created_at,
                                                                                         :updated_at] }
                                                                        }
                                                                 ) }
    end
  end

#################################################################

  def chart
    render :inline => "<%= stylesheet_link_tag $layout_public_path + '/css/general.css' %><%= javascript_include_tag :defaults %><%= canvas_for_model_in_inventory_pools(@model, @current_inventory_pools) %>"
  end

#################################################################

  private
  
  def pre_load
    params[:model_id] ||= params[:id] if params[:id]
    @model = current_user.models.find(params[:model_id]) if params[:model_id]
    @inventory_pool = current_user.inventory_pools.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
  end


end
