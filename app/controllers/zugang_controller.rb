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
class ZugangController < ApplicationController
 
	include LoginSystem
	
	layout 'allgemein'

	def index
		redirect_to :action => 'login'
	end
	
	def login
		# Einloggen und identifizieren eines Benutzers
		unless request.post?
			# loesche Session, aber bewahre den redirect
			@redirect = session[ :return_to ]
			reset_session
			session[ :return_to ] = @redirect
			session[ :hilfeseite ] = 'index'
			
		else
			@user = User.authenticate( params[ :user_login ].first, params[ :user_password ].first )
			
			unless @user
				# keine sinnvolle Authentifizierung möglich
				flash[ :notice ] = "Login nicht möglich. Falscher Benutzername oder falsches Passwort?"
				logger.debug( "C --- zugang | login -- params:#{params}" )
				if params[ :user_login ].first.include?( '@hgkz' ) or params[ :user_login ].first.include?( '@hmt' )
          flash[ :notice ] = "Alle Logins wurden auf ZHdK E-Mail Adressen umgeschrieben. Bitte melden Sie sich mit Ihrer E-Mail @zhdk.ch an."
        end
			
			else
				# User erfolgreich identifiziert
				unless @user.benutzerstufe > 0
					flash[ :notice ]  = "Dieser Benutzer ist <b>gesperrt</b>"
					
				else
					# User hat Berechtigung fuer das System
					@user.password = 'password'
					unless @user.update_attribute( :login_als, @user.benutzerstufe )
						flash[ :notice ]  = "Konnte login nicht in die DB schreiben"
					else
						
						# Login erfolgreich in die DB geschrieben
						session[ :user ] = @user
						session[ :aktiver_geraetepark ] = 0
						session[ :aktiver_geraetepark ] = @user.gib_exklusiven_geraetepark.id
						session[ :hilfe_aus ] = true if @user.herausgeber?
						Logeintrag.neuer_eintrag( @user, 'login' )
						
						case @user.benutzer_typ
							when :reservierender
								#logger.debug( "I --- Login mit Berechtigung, redirect nach haupt/status" )
								flash[ :notice ]  = "Erfolgreich angemeldet"
								session[ :hilfeseite ] = 'index'
								redirect_back_or_default(
											:controller => 'reservations',
											:action => 'meine' )
							when :herausgeber, :admin, :root
								flash[ :notice ]  = "Erfolgreich als Herausgeber angemeldet"
								redirect_back_or_default(
											:controller => 'admin',
											:action => 'status' )
						end
					end
				end
			end
		end
	end
  
	def signup
		session[ :hilfeseite ] = 'zugang_einrichten'
		
		unless request.post?
			@user = User.new
			
		else
			# eMail Adresse zusammensetzen
			#logger.debug( "I--- zugang con | signup -- params hash 2:#{params_hash.to_yaml}" )
			
			@user = User.new( params[ :user ] )
			@user.email_suffix = 'zhdk.ch' unless @user.email_suffix.length > 1
			@user.login = @user.email
			@user.updater_id = session[ :user ] || nil
			@user.created_at = Time.now
			@user.benutzerstufe = 0
			
			if @user.valid_fuer_signup?
				if @user.save
					@user.reload
					Logeintrag.neuer_eintrag( @user, 'richtet Zugang ein', "Benutzer #{@user.id}" )
					
					# Email senden
					email = LeihsMailer.deliver_aktivierung( @user )
					render :action => 'signup_ok'
					
				else
					flash[ :notice ]  = "Benutzer konnte nicht in die DB geschrieben werden. Bitte wenden Sie sich an einen Administrator"
				end
			
			else
				Logeintrag.neuer_eintrag( nil, 'Zugang falsch ausgefüllt',
							"#{@user.nachname} #{@user.vorname} #{@user.email}" )
			end
		end
	end
	
	def aktivieren
		if User.aktiviere_mit_token( params[ :token ] )
			flash[ :notice ] = 'Benutzer wurde erfolgreich aktiviert. Sie können sich nun einloggen'
		else
			flash[ :notice ] = 'Benutzer konnte nicht aktiviert werden'
		end
		redirect_to :action => 'login'
	end
	
	def logout
		keine_hilfe
		if session[ :user ]
			@user = session[ :user ]
			@user.reload
			if @user
				@user.password = ''
				@user.update_attribute( :login_als, 0 )
				Logeintrag.neuer_eintrag( @user, 'logout' )
				session[ :user ] = nil
				reset_session
			end
		end
	end

end
