class GeraeteparksController < ApplicationController

	include LoginSystem
	before_filter :admin_required, :except => [ 'hilfe_einblenden' ]
	before_filter :login_required, :only => [ 'hilfe_einblenden' ]
	
	layout 'allgemein'

#----------------------------------------------------------
	
  def edit
		session[ :hilfeseite ] = 'geraetepark_mutieren'
    @geraetepark = Geraetepark.find(params[:id])
  end

  def update
    @geraetepark = Geraetepark.find( params[ :id ] )
		logger.debug( "I --- Geraetepark:#{params[:geraetepark]}" )
		neue_params = params[ :geraetepark ]
		neue_params[ :updater_id ] = session[ :user ].id if session[ :user ]
		
    if @geraetepark.update_attributes(params[:geraetepark])
      flash[:notice] = 'Geraetepark was successfully updated.'
      redirect_to :controller => 'haupt', :action => 'info'
    else
      render :action => 'edit'
    end
  end

	def hilfe_einblenden
		@geraetepark = Geraetepark.find( params[ :id ] )
		render( :partial => 'infos', :locals => {
					:geraetepark => @geraetepark } )
	end
	
end
