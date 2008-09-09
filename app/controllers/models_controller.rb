class ModelsController < FrontendController

  # TODO prevent sql injection
  def index( category_id = params[:category_id],
             start = (params[:start] || 0).to_i,
             limit = (params[:limit] || 25).to_i,
             query = params[:query],
             recent = params[:recent],
             sort =  "models.#{params[:sort]}" || "models.name",
             dir =  params[:dir] || "ASC" )
    if category_id
      #old# @models = Category.find(category_id).models.find(:all, :offset => start, :limit => limit, :order => "#{sort} #{dir}") & current_user.models
      #old# c = (Category.find(category_id).models & current_user.models).size
      # OPTIMIZE intersection
      category = Category.find(category_id)
      @models = (category.children.recursive.to_a << category).collect(&:models).flatten & current_user.models.all(:conditions => ["inventory_pools.id IN (?)", current_inventory_pools])
      c = @models.size
    elsif query
      # TODO searcheable by property values
      @models = current_user.models.find_by_contents("*" + query + "*", {:offset => start,
                                                                         :limit => limit,
                                                                         :order => "#{sort} #{dir}"},
                                                                         :conditions => ["inventory_pools.id IN (?)", current_inventory_pools])
      # TODO include Templates
      # @models = current_user.models.find_by_contents("*" + query + "*", {:offset => start, :limit => limit, :order => "#{sort} #{dir}", :multi => [Template]})
      # TODO fix total_hits with has_many
      c = @models.total_hits
    elsif recent
      @models = current_user.orders.sort.collect(&:models).flatten.uniq[0,limit]
      @models ||= []
      c = @models.size
    else
      @models = current_user.models.find(:all,
                                         :offset => start,
                                         :limit => limit,
                                         :order => "#{sort} #{dir}",
                                         :conditions => ["inventory_pools.id IN (?)", current_inventory_pools])
      # TODO fix 
      c = current_user.models.count(:all,
                                    :conditions => ["inventory_pools.id IN (?)", current_inventory_pools])
    end
    respond_to do |format|
      format.ext_json { render :json => @models.to_ext_json(:count => c #,
#                                                            :include => {
#                                                                :inventory_pools => { :except => [:description,
#                                                                                                  :logo_url,
#                                                                                                  :contract_url,
#                                                                                                  :contract_description] } }
                                                                 ) }
    end
  end  

  # TODO interesections
  def categories(id = params[:node].to_i)
    if id == 0 
#      c = Category.roots
#      c = current_user.categories.roots
      c = current_user.all_categories & Category.roots
    else
      # OPTIMIZE intersection
      c = current_user.categories & Category.find(id).children # TODO scope only children Category (not ModelGroup)
#      c = current_user.categories.find(id).children
#      c = current_user.all_categories.find(id).children
    end
    respond_to do |format|
      format.ext_json { render :json => c.to_json(:methods => [:text, :leaf]) } # .to_a.to_ext_json
    end
  end
  
#######################################################  
  
  # TODO optimize html rendering to extjs
  def details(model_id = params[:model_id] || params[:id]) # TODO remove :id
    @model = current_user.models.find(model_id)
    render :partial => 'details'
#    respond_to do |format|
#      format.ext_json { render :json => @model.to_json(:include => :inventory_pools) }
#    end
  end

end
