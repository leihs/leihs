class <%= controller_class_name %>Controller < ApplicationController

  before_filter :find_<%= file_name %>, :only => [ :show, :edit, :update, :destroy ]

  # GET /<%= table_name %>
  # GET /<%= table_name %>.ext_json
  def index
    respond_to do |format|
      format.html     # index.html.erb (no data required)
      format.ext_json { render :json => find_<%= table_name %>.to_ext_json(:class => :<%= file_name %>, :count => <%= class_name %>.count) }
    end
  end

  # GET /<%= table_name %>/1
  def show
    # show.html.erb
  end

  # GET /<%= table_name %>/new
  def new
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])
    # new.html.erb
  end

  # GET /<%= table_name %>/1/edit
  def edit
    # edit.html.erb
  end

  # POST /<%= table_name %>
  def create
    @<%= file_name %> = <%= class_name %>.new(params[:<%= file_name %>])

    respond_to do |format|
      if @<%= file_name %>.save
        flash[:notice] = '<%= class_name %> was successfully created.'
        format.ext_json { render(:update) {|page| page.redirect_to <%= table_name %>_url } }
      else
        format.ext_json { render :json => @<%= file_name %>.to_ext_json(:success => false) }
      end
    end
  end

  # PUT /<%= table_name %>/1
  def update
    respond_to do |format|
      if @<%= file_name %>.update_attributes(params[:<%= file_name %>])
        flash[:notice] = '<%= class_name %> was successfully updated.'
        format.ext_json { render(:update) {|page| page.redirect_to <%= table_name %>_url } }
      else
        format.ext_json { render :json => @<%= file_name %>.to_ext_json(:success => false) }
      end
    end
  end

  # DELETE /<%= table_name %>/1
  def destroy
    @<%= file_name %>.destroy

    respond_to do |format|
      format.js  { head :ok }
    end
  rescue
    respond_to do |format|
      format.js  { head :status => 500 }
    end
  end
  
  protected
  
    def find_<%= file_name %>
      @<%= file_name %> = <%= class_name %>.find(params[:id])
    end
    
    def find_<%= table_name %>
      pagination_state = update_pagination_state_with_params!(:<%= file_name %>)
      @<%= table_name %> = <%= class_name %>.find(:all, options_from_pagination_state(pagination_state).merge(options_from_search(:<%= file_name %>)))
    end

end
