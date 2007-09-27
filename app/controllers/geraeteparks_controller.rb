#    This file is part of leihs.
#
#    leihs is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    leihs is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    leihs is (C) Zurich University of the Arts
#    
#    This file was written by:
#    Magnus Rembold
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
