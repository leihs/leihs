module LeihsAdmin
  class SuppliersController < AdminController

    before_action only: [:edit, :update, :destroy] do
      @supplier = Supplier.find(params[:id])
    end

    def index
      @suppliers = Supplier.filter(params)
    end

    def new
      @supplier = Supplier.new
    end

    def create
      @supplier = Supplier.create params[:supplier]
      if @supplier.persisted?
        flash[:notice] = _('Supplier successfully created')
        redirect_to action: :index
      else
        flash.now[:error] = @supplier.errors.full_messages.uniq.join(', ')
        render :new
      end
    end

    def edit
      @items = @supplier.items.order(:inventory_pool_id).includes(:model, :inventory_pool)
    end

    def update
      if @supplier.update_attributes params[:supplier]
        flash[:notice] = _('Supplier successfully updated')
        redirect_to action: :index
      else
        flash.now[:error] = @supplier.errors.full_messages.uniq.join(', ')
        render :edit
      end
    end

    def destroy
      begin
        @supplier.destroy
        flash[:success] = _('%s successfully deleted') % _('Supplier')
      rescue => e
        flash[:error] = e.to_s
      end
      redirect_to action: :index
    end

  end


end
