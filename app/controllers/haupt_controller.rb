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
class HauptController < ApplicationController

	include LoginSystem
	before_filter :login_required, :only => [ 'status', 'setze_berechtigung', 'edit_mich', 'update_mich' ]
	before_filter :admin_required, :only => [ 'testmail' ]

	layout 'allgemein'

	def index
		reset_session
		session[ :hilfeseite ] = 'index'
		@geraeteparks = Geraetepark.find( :all, :order => 'oeffentlich DESC, name' )
	end

	def status
		redirect_to :controller => 'reservations', :action => 'meine'
	end
	
	def info
		session[ :hilfeseite ] = 'geraetepark_infos'
		#init_flash_fuer_hilfeseite
	end
	
	def setze_berechtigung
		session[ :aktiver_geraetepark ] = params[ :id ].to_i if session[ :user ] and session[ :user ].hat_berechtigung?( params[ :id ].to_i )
		info
		if session[ :user ].herausgeber?
			redirect_to :controller => 'admin', :action => 'status'
		else
			redirect_to :controller => 'haupt', :action => 'info'
		end
	end
	
	def edit_mich
		keine_hilfe
		@user = User.find( session[ :user ].id )
		@email_prefix = @user.email.split( '@' ).first
		@user.password = ''
	end
	
	def update_mich
		@user = User.find( session[ :user ].id )
		logger.debug( "I --- users_con -- update mich -- user:#{@user.to_yaml}")
		@user.attributes = params[ :user ]
		@user.updater_id = session[ :user ].id
		if @user.valid_fuer_update?
			if @user.save
				Logeintrag.neuer_eintrag( @user, 'ändert seine Stammdaten' )
				session[ :user ] = @user
				flash[ :notice ] = 'Benutzer wurde erfolgreich geändert'
				redirect_to :action => 'status'
			else
				render :action => 'edit_mich'
			end
			
		else
			render :action => 'edit_mich'
		end
	end
	
	def testmail
		email = LeihsMailer.deliver_aktivierung( User.find( params[ :id ] ) )
		logger.debug( "I --- mail #{email.to_yaml}" )
		render :text => "Mail #{params[ :id]} done..."
	end
		
end
