class KaufvorgangsController < ApplicationController

	include LoginSystem
	layout 'allgemein'
	before_filter :admin_required

  def index
    redirect_to :controller => 'gegenstands', :action => 'list' 
  end

  def show
    @kaufvorgang = Kaufvorgang.find(params[:id])
    @gegenstand = Gegenstand.find( @kaufvorgang.gegenstand.id )
  end

  def new
		@gegenstand = Gegenstand.find( params[ :id ] )
    @kaufvorgang = Kaufvorgang.new
  end

  def create
  	@gegenstand = Gegenstand.find( params[ :id ] )
    @kaufvorgang = Kaufvorgang.new( params[ :kaufvorgang ] )
    if @kaufvorgang.save
			@gegenstand.kaufvorgang_id = @kaufvorgang.id
			if @gegenstand.save
				flash[ :notice ] = 'Kaufvorgang wurde eingetragen.Gegenstand aktualisiert'
	      redirect_to :controller => 'gegenstands', :action => 'list'
	    else
	    	flash[ :notice ] = 'Kaufvorgang wurde eingetragen.Gegenstand konnte nicht aktualisiert werden.'
    	  render_action 'new'
			end
		else
			flash[ :notice ] = 'Kaufvorgang konnte nicht eingetragen werden.'
			render_action 'new'
    end
  end

	def edit
		show
	end

  def update
    @kaufvorgang = Kaufvorgang.find( params[ :id ] )
    if @kaufvorgang.update_attributes( params[ :kaufvorgang ] )
      flash[ :notice ] = 'Kaufvorgang wurde geaendert.'
      redirect_to :controller => 'gegenstands', :action => 'edit', :id => @kaufvorgang.gegenstand.id
    else
      render_action 'edit'
    end
  end

  def destroy
    @kaufvorgang = Kaufvorgang.find( params[ :id ] )
		@gegenstand_id = @kaufvorgang.gegenstand.id
		@kaufvorgang.destroy
    redirect_to :controller => 'gegenstands', :action => 'edit', :id => @gegenstand_id
  end
end
