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
			@user = User.authenticate( params[ :user_login ], params[ :user_password ] )
			
			unless @user
				# keine sinnvolle Authentifizierung möglich
				flash[ :notice ]  = "Login nicht möglich. Falscher Benutzername oder falsches Passwort?"
			
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
			@user.login = @user.email
			@user.updater_id = @user.id || nil
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
				flash[ :notice ] = "Zugangsregistration ist nicht richtig ausgefüllt"
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
