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
class UsersController < ApplicationController
	
	include LoginSystem
	before_filter :herausgeber_required
	before_filter :keine_hilfe

	layout 'allgemein'
	
	def index
		list
		render :action => 'list'
	end
	
	def list
		fuer_geraetepark = Geraetepark.find_by_name( params[ :id ] )
		fuer_geraetepark_id = fuer_geraetepark ? fuer_geraetepark.id : nil
		buchstabe = params[ :buchstabe ]
		sortierung = params[ :sort ]
		updown = ( params[ :updown ].blank? ? '' : ( params[ :updown ].to_i > 0 ? ' ASC' : ' DESC' ) )
    
		logger.debug( "I --- user con | list -- berechtigung:#{fuer_geraetepark}, buchstabe:#{buchstabe}, sortierung:#{sortierung}" )
		@buchstaben = User.find_buchstaben_fuer_berechtigung( fuer_geraetepark_id )
		@users = [ ]
		unless buchstabe.blank?
			@users = User.find_fuer_berechtigung( fuer_geraetepark_id,
						{ :buchstabe => buchstabe } )
		else
  		if sortierung
  			@users = User.find( :all,
  						:include => [ 'reservations', 'berechtigungs' ],
  						:conditions => ( fuer_geraetepark ? [ 'geraeteparks.name = ?', fuer_geraetepark.name ] : 'true' ),
  						:order => sortierung + updown )
  			unless fuer_geraetepark.nil?
  				logger.debug( "I--- user con | list -- fuer berech #{fuer_geraetepark}" )
  				#@users.delete_if { |u| !u.hat_berechtigung?( fuer_geraetepark ) }
  			end
  		end
  	end
	end
	
	def search_for_list
		logger.debug( "I --- users con | search for list -- params:#{params.to_yaml}" )
		@users = User.find( :all,
					:conditions => [ "nachname like ? or vorname like ?", params[ :namesuche ].to_s + '%', params[ :namesuche ].to_s + '%' ],
					:order => 'nachname' )
		
		if @users.size > 0 and @users.size < 30
			render :partial => 'suchresultate'
		else
			render :text => "<?xml version='1.0' encoding='utf-8'?>"
		end
	end
	
	def show
		@user = User.find( params[ :id ], :include => [ :reservations ] )
	end
	
	def edit
		@user = User.find( params[ :id ] )
		@user.password = ''
	end
	
	def update
		params_hash = params[ :user ]
		if params_hash[ :password ] == ''
			params_hash[ :password ] = ''
			params_hash[ :password_confirmation ] = ''
		end
		logger.debug( "I --- users_controller --- params:#{params.to_yaml} --- params_hash:#{params_hash.to_yaml}")
		
		@user = User.find( params[ :id ] )
		logger.debug( "I --- users_controller --- user:#{@user.to_yaml}")
		@user.update_attributes( params_hash )
		@user.updater_id = session[ :user ].id if session[ :user ]
		@user.password = ''
		@user.password_confirmation = ''
		
		if @user.save
			if params[ :berechtigungen ]
				# neue Berechtigungen eintragen
				for berechtigung_key, berechtigung_value in params[ :berechtigungen ]
					logger.debug( "I --- b_key:#{berechtigung_key.to_yaml}, b_value:#{berechtigung_value.to_yaml}" )
					if berechtigung_value.to_i == 1
						@user.berechtigungs |= [ Geraetepark.find( berechtigung_key.to_i ) ]
					else
						@user.berechtigungs.delete( Geraetepark.find( berechtigung_key.to_i ) )
					end
				end
			end
			
			@user.reload
			Logeintrag.neuer_eintrag( session[ :user ], 'hat Benutzer verändert', "Benutzer #{@user.id}" )
			flash[ :notice ] = 'Benutzer wurde erfolgreich geändert'
			redirect_to :action => 'show', :id => @user.id
		else
			render_action 'edit'
		end
		logger.debug( "I --- users con | update -- user:#{@user.to_yaml}" )
	end
	
	def destroy
		User.find( params[ :id ] ).destroy
		redirect_to :action => 'list'
	end
	
end
