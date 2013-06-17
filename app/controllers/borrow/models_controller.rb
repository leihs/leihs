class Borrow::ModelsController < Borrow::ApplicationController

  def index
    @category = Category.find_by_id params[:category_id]
    @models = if @category then @current_user.models.from_category_and_all_its_descendants(@category.id) else Model.scoped end
    @models = @models.all_from_inventory_pools(@current_user.inventory_pools.where(id: params[:inventory_pool_ids]).map(&:id)) unless params[:inventory_pool_ids].blank?
    @models = @models.search(params[:searchTerm], [:name, :manufacturer]) unless params[:searchTerm].blank?
    @models = @models.order_by_attribute_and_direction params[:sort], params[:order]
    @models = @models.paginate(:page => params[:page]||1, :per_page => 20)
    set_pagination_header
    respond_to do |format|
      format.json 
      format.html {
        @child_categories = @category.children
        @child_categories.reject! {|c| @models.from_category_and_all_its_descendants(c).active.blank?}
        @grand_children = {}
        @child_categories.each do |category|
          @grand_children[category.id] = category.children.reject{|c| @models.from_category_and_all_its_descendants(c).active.blank?}
        end
        @inventory_pools = current_user.inventory_pools.order(:name)
      }
    end
  end

  def show
    @model = Model.find(params[:id])
    respond_to do |format|
      format.json
    end
  end

  def availability
    models = current_user.models.where(:id => params[:model_ids])
    start_date = Date.parse(params[:start_date])
    end_date = Date.parse(params[:end_date])
    inventory_pools = current_user.inventory_pools.where(:id => params[:inventory_pool_ids])
    @availability = models.map do |model|
      inventory_pools.map do |ip|
        {
         :model_id => model.id,
         :inventory_pool_id => ip.id,
         :quantity => model.availability_in(ip).maximum_available_in_period_summed_for_groups(start_date, end_date, current_user.groups.map(&:id))
        }
      end
    end
    @availability.flatten!
  end

  private ###########

  def set_pagination_header
    headers["X-Pagination"] = {
      total_count: @models.count,
      per_page: @models.per_page,
      offset: @models.offset
    }.to_json
  end

end
