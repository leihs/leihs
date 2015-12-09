class Manage::ModelsController < Manage::ApplicationController

  private

  # NOTE overriding super controller
  def required_manager_role
    open_actions = [:timeline]
    if not open_actions.include?(action_name.to_sym) \
      and (request.post? or not request.format.json?)
      super
    else
      require_role :group_manager, current_inventory_pool
    end
  end

  public

  def index
    @models = Model.filter params, current_inventory_pool
    set_pagination_header(@models) unless params[:paginate] == 'false'
  end

  def show
    @model = fetch_model
  end

  def new
    not_authorized! unless privileged_user?
    @model = (params[:type].try(:humanize) || 'Model').constantize.new
  end

  def create
    not_authorized! unless privileged_user?
    ActiveRecord::Base.transaction do
      @model = case params[:model][:type]
               when 'software'
                   Software
               else
                   Model
               end.create(product: params[:model][:product],
                          version: params[:model][:version])
      if save_model @model
        render status: :ok, json: { id: @model.id }
      else
        render status: :bad_request,
               text: @model.errors.full_messages.uniq.join(', ')
      end
    end
  end

  def edit
    @model = fetch_model
  end

  def update
    not_authorized! unless privileged_user?
    @model = fetch_model
    ActiveRecord::Base.transaction do
      if save_model @model
        head status: :ok
      else
        render status: :bad_request,
               text: @model.errors.full_messages.uniq.join(', ')
      end
    end
  end

  def upload
    @model = fetch_model
    params[:files].each do |file|
      if params[:type] == 'image'
        image = @model.images.build(file: file, filename: file.original_filename)
        image.save
      elsif params[:type] == 'attachment'
        attachment = Attachment.new(file: file,
                                    filename: file.original_filename,
                                    model_id: @model.id)
        attachment.save
      end
    end
    head status: :ok
  end

  def destroy
    @model = fetch_model
    begin
      @model.destroy
      respond_to do |format|
        format.json { render json: true, status: :ok }
        format.html do
          redirect_to \
            manage_inventory_path(current_inventory_pool),
            flash: { success: _('%s successfully deleted') % _('Model') }
        end
      end
    rescue => e
      @model.errors.add(:base, e)
      text = @model.errors.full_messages.uniq.join(', ')
      respond_to do |format|
        format.json { render text: text, status: :forbidden }
        format.html do
          redirect_to \
            manage_inventory_path(current_inventory_pool),
            flash: { error: text }
        end
      end
    end
  end

  def timeline
    @model = fetch_model
    respond_to do |format|
      format.html { render layout: false }
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
      if package['id'].blank?
        ActiveRecord::Base.transaction do
          item = Item.new
          data = package.merge owner_id: current_inventory_pool.id,
                               model: @model
          data[:inventory_code] ||= \
            "P-#{Item.proposed_inventory_code(current_inventory_pool)}"
          item.update_attributes data
          children['id'].each do |child|
            item.children << Item.find_by_id(child)
          end
          flash[:success] = "#{_('Model saved')} / #{_('Packages created')}"
        end
      else
        item = Item.find_by_id(package['id'])
        if package['_destroy'] == '1'
          if item.reservations.empty?
            item.destroy
          else
            item.retired = true
            item.retired_reason = format('%s %s', _('Package'), _('Deleted'))
            item.save
          end
          next
        elsif item
          package.delete '_destroy'
          item.update_attributes package
          if children
            item.children = []
            children['id'].each do |child|
              item.children << Item.find_by_id(child)
            end
          end
        end
        flash[:success] = "#{_('Model saved')} / #{_('Packages updated')}"
      end
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
    params[:model].delete(:type)
    model.update_attributes(params[:model]) and model.save
  end

end
