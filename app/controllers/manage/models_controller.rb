class Manage::ModelsController < Manage::ApplicationController

  private

  # NOTE overriding super controller
  def required_manager_role
    open_actions = [:timeline]
    if not open_actions.include?(action_name.to_sym) and (request.post? or not request.format.json?)
      require_role :lending_manager, current_inventory_pool
    else
      require_role :group_manager, current_inventory_pool
    end
  end

  public

  def index
    @models = Model.filter params, current_inventory_pool
    set_pagination_header(@models) unless params[:paginate] == "false"
  end

  def show
    @model = fetch_model
  end

  def new
    not_authorized! unless is_privileged_user?
    @model = (params[:type].try(:humanize) || "Model").constantize.new
  end
  
  def create
    not_authorized! unless is_privileged_user?
    ActiveRecord::Base.transaction do
      @model = case params[:model][:type]
                 when "software"
                   Software
                 else
                   Model
               end.create(product: params[:model][:product], version: params[:model][:version])
      if save_model @model
        render :status => :ok, :json => {id: @model.id}
      else
        render :status => :bad_request, :text => @model.errors.full_messages.uniq.join(", ")
      end
    end
  end

  def edit
    @model = fetch_model
  end

  def update
    not_authorized! unless is_privileged_user?
    @model = fetch_model
    ActiveRecord::Base.transaction do
      if save_model @model
        render :status => :no_content, :nothing => true
      else
        render :status => :bad_request, :text => @model.errors.full_messages.uniq.join(", ")
      end
    end
  end

  def upload
    @model = fetch_model
    params[:files].each do |file|
      if params[:type] == "image"
        image = @model.images.build(:file => file, :filename => file.original_filename)
        image.save
      elsif params[:type] == "attachment"
        attachment = Attachment.new :file => file, :filename => file.original_filename, :model_id => @model.id
        attachment.save
      end
    end
    render status: :no_content, nothing: true
  end

  def destroy
    @model = fetch_model
    begin @model.destroy
      respond_to do |format| 
        format.json {render :json => true, status: :ok}
        format.html {redirect_to manage_inventory_path(current_inventory_pool), flash: {success: _("%s successfully deleted") % _("Model")}}
      end
    rescue => e
      @model.errors.add(:base, e)
      text = @model.errors.full_messages.uniq.join(", ")
      respond_to do |format| 
        format.json {render :text => text, :status => :forbidden}
        format.html {redirect_to manage_inventory_path(current_inventory_pool), flash: {error: text}}
      end
    end
  end

  def handle_compatibles
    @model.compatibles.destroy_all
    if @compatibles
      @compatibles.each do |compatible|
        @model.compatibles << Model.find_by_id(compatible[:id])
      end
    end
  end

  def details
  end

  def max_partition_capacity
    max_partition_capacity = Model.find(params[:id]).items.where(inventory_pool_id: current_inventory_pool).borrowable.count
    respond_to {|format| format.json {render json: max_partition_capacity}}
  end

  def set_group_partition
    @model.partitions.set_in(current_inventory_pool, params[:groups])
    flash[:notice] = _("The group quantities were successfully saved.")
    redirect_to :action => :show
  end

  def package
    new_package_root if @model.items.empty?
  end

  def new_package
    @model = Model.new
    render :action => 'package'
  end

  def update_package
    @model ||= Model.find_by_name(params[:model][:name])
    @model ||= Model.new(:is_package => true)
    if not @model.is_package?
      flash[:error] = _("The selected model is not a package")
      return
    end
    if @model.update_attributes(params[:model])
      flash[:notice] = _("Package successfully saved")
      redirect_to package_manage_inventory_pool_model_path(current_inventory_pool, @model, :filter => params[:filter])
    else
      flash[:error] = _("Error saving the package")
      render :action => 'package'
    end
  end
  
  def destroy_package
    if @model.destroy
      flash[:notice] = _("Package successfully destroyed")
    else
      flash[:error] = _("Error destroying the package")
    end
    redirect_to manage_models_path(current_inventory_pool, :packages => true)
  end

  #2408#
  def package_roots
    if request.put?
      if @model.items.find(params[:root_id]).update_attributes(:inventory_code => params[:inventory_code])
        flash[:notice] = _("Inventory code updated")
      else
        flash[:error] = _("Error updating inventory code")
      end
    elsif request.delete?
      if @model.items.find(params[:root_id]).destroy
        flash[:notice] = _("Item package successfully destroyed")
      else
        flash[:error] = _("Error destroying the item package")
      end
    elsif request.post?
      new_package_root
    end

    get_root_items
  end
  
  def get_root_items
    @root_items = case params[:filter]
                    when "own", "own_items"
                      current_inventory_pool.own_items.where(model_id: @model)
                    else
                      current_inventory_pool.items.where(model_id: @model)
                  end
  end

  def new_package_root
    m = @model.items.build(:inventory_code => "P-#{Item.proposed_inventory_code(current_inventory_pool)}",
                           :inventory_pool => current_inventory_pool,
                           :is_borrowable => true)

    flash[:error] = m.errors.full_messages.uniq unless m.save
  end

  def package_item
    root_item = @model.items.find(params[:root_id]) 
    if request.put?
      if @item.model.is_package?
        flash[:error] = _("You can't add a package to a package.")
      else
        root_item.children << @item
      end
    elsif request.delete?
      root_item.children.delete(@item)
    end
    get_root_items
    render :action => 'package_roots'
  end

  def properties
    if request.post?
      # TODO 0408** Rails 2.3: accepts_nested_attributes_for
      @model.properties.destroy_all
      params[:properties].delete_if {|p| p[:key].blank? or p[:value].blank? }
      @model.properties.create(params[:properties])
      @model.touch
      flash[:notice] = _("The properties have been updated.")
    end
    # TODO 0408** scope @model.categories
    @properties_set = Model.with_properties.collect{|m| m.properties.collect(&:key)}.uniq
  end

  def timeline
    @model = fetch_model
    respond_to do |format|
      format.html { render :layout => false}
    end
  end

  private

  def fetch_model
    Model.filter(params).first
  end

  def update_packages(packages)
    packages.each do |package|
      package = package[1]
      children = package.delete(:children)
      if package["id"].blank?
        item = Item.new
        data = package.merge :inventory_code => "P-#{Item.proposed_inventory_code(current_inventory_pool)}",
                             :owner_id => current_inventory_pool.id,
                             :model => @model
        item.update_attributes data
        children["id"].each do |child|
          item.children << Item.find_by_id(child)
        end
        flash[:success] = "#{_("Model saved")} / #{_("Packages created")}"
      else
        item = Item.find_by_id(package["id"])
        if package["_destroy"] == "1"
          item.destroy()
          next
        elsif item
          package.delete "_destroy"
          item.update_attributes package
          if children
            item.children = []
            children["id"].each do |child|
              item.children << Item.find_by_id(child)
            end
          end
        end
        flash[:success] = "#{_("Model saved")} / #{_("Packages updated")}"
      end
      item.save!
    end
  end

  private

  def save_model(model)
    # PACKAGES
    packages = params[:model].delete(:packages)
    if packages
      @model.is_package = true
      update_packages packages
    end
    # COMPATIBLES
    model.compatibles = []
    # PROPERTIES
    model.properties.destroy_all
    # REMAINING DATA
    model.update_attributes(params[:model]) and model.save
  end

end
