class ModelsController < FrontendController

  before_filter :pre_load

  def index( category_id = params[:category_id].to_i, # TODO 18** nested route ?
             start = (params[:start] || 0).to_i,
             limit = (params[:limit] || 25).to_i,
             query = params[:query],
             sort = params[:sort] || 'name', # OPTIMIZE 0501
             sort_mode = params[:dir] || 'ASC' ) # OPTIMIZE 0501
    
    sort_mode = sort_mode.downcase.to_sym # OPTIMIZE 0501

    #1402 TODO refactor to User#accessible_models(current_inventory_pools)
    model_ids = Model.all(:select => "DISTINCT models.id",
                          :joins => [:items, :partitions],
                          :conditions => ["items.inventory_pool_id IN (:ip_ids)
                                             AND (partitions.group_id IN (:groups_ids)
                                             OR (partitions.group_id IS NULL AND partitions.inventory_pool_id IN (:ip_ids)))",
                                          {:ip_ids => current_inventory_pools.collect(&:id),
                                           :groups_ids => current_user.group_ids}
                                         ]).collect(&:id)
#tmp#
#    model_ids = Model.all(:select => "DISTINCT models.id",
#                          :joins => :items,
#                          :conditions => {:items => {:inventory_pool_id => current_inventory_pools.collect(&:id)}}).collect(&:id)
#    group_ids = current_user.group_ids_including_general
#    model_ids = model_ids.select {|m_id|  } or #model_ids.delete_if {|m|  }

    with = {:sphinx_internal_id => model_ids }

    if category_id > 0
      category = Category.find(category_id)
      with[:category_id] = category.self_and_all_child_ids
    end

    @models = Model.search query, { :index => "frontend_model",
                                    :star => true,
                                    :offset => start, :limit => limit, # :page => ((start / limit) + 1), :per_page => limit,
                                    :with => with,
                                    :order => sort, :sort_mode => sort_mode }

    respond_to do |format|
      format.ext_json { render :json => @models.to_ext_json(:class => "Model",
                                                            :count => @models.total_entries,
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
                                                                                      :methods => [[:items_size, @model, current_user]],
                                                                                      :only => [:id, :name] },
                                                                :images => { :methods => [:public_filename, :public_filename_thumb],
                                                                             :except => [:created_at,
                                                                                         :updated_at] },
                                                                :attachments => { :methods => [:public_filename],
                                                                                  :except => [:model_id,
                                                                                              :is_main,
                                                                                              :content_type] }
                                                                        }
                                                                 ) }
    end
  end

#################################################################

  def chart
    #render :inline => "<%= stylesheet_link_tag $layout_public_path + '/css/general.css' %><%= javascript_include_tag :defaults %><%= canvas_for_model_in_inventory_pools(@model, @current_inventory_pools) %>"
    render :layout => false
  end

#################################################################

  private
  
  def pre_load
    params[:model_id] ||= params[:id] if params[:id]
    @model = current_user.models.find(params[:model_id]) if params[:model_id]
    @inventory_pool = current_user.inventory_pools.find(params[:inventory_pool_id]) if params[:inventory_pool_id]
  end


end
