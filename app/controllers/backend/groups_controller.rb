class Backend::GroupsController < Backend::BackendController
  def index
    # OPTIMIZE 0501 
    params[:sort] ||= 'name'
    params[:sort_mode] ||= 'ASC'
    params[:sort_mode] = params[:sort_mode].downcase.to_sym

    with = {}
    
    if params[:group_id]
      sphinx_select = "*, inventory_pool_id = #{current_inventory_pool.id} AS a"
      with.merge!(:group_id => @group.id, :a => true)
    end    

    with.merge!(:inventory_pool_id => current_inventory_pool.id)
    
    page = params[:page]
    per_page = $per_page
    
    puts "***1***"
    puts params[:query]
    gaga = { :star => true, :page => page, :per_page => per_page,
                                             :sphinx_select => sphinx_select,
                                             :with => with,
                                             :sort_mode => params[:sort_mode] }
    puts gaga.inspect
    @groups = Group.search params[:query], { :star => true, :page => page, :per_page => per_page,
                                             :sphinx_select => sphinx_select,
                                             :with => with,
                                             :order => params[:sort], :sort_mode => params[:sort_mode]}
    puts "***2***"
    puts @groups.inspect

    respond_to do |format|
      format.html
      format.js { search_result_rjs(@groups) }
      format.auto_complete { render :layout => false }
    end
  end

  def show
    if @group.nil?
      flash[:error] = _("You don't have access to this group.")
      redirect_to backend_inventory_pool_groups_path(current_inventory_pool)
    end
  end

end
