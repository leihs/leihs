class ReservationsController < ApplicationController
	
	include LoginSystem
	before_filter :herausgeber_required, :except => [ 'meine', 'destroy' ]
	before_filter :login_required, :only => [ 'meine', 'destroy' ]

	layout 'allgemein'
	
  def index
		list
    render :action => 'list'
  end
	def list
		@t_start = Time.now
		session[ :hilfeseite ] = 'reservationen_liste'
		
		@filter = session[ :reservation_filter ] ||= Filter.new(
					:selectliste => Reservation.felder_selectliste )
		filterbedingung = "geraetepark_id = #{session[ :aktiver_geraetepark ].to_i}"
		if @filter.bedingung
			filterbedingung += " and "
			filterbedingung += @filter.bedingung
		end

		@reservation_pages, @reservations = paginate( 'reservation',
					:include => 'user',
					:conditions => filterbedingung.length > 0 ? filterbedingung : nil,
					:order => 'reservations.updated_at DESC',
					:per_page => 25 )
		@reservations_anzahl = Reservation.count( :conditions => [ 'geraetepark_id = ?', session[ :aktiver_geraetepark ] ] )
	end

#----------------------------------------------------------
# Filter & Sortierung setzen oder aendern

	def setze_filter
		filter_init = { }
		filter_init[ :selectliste ] = Reservation.felder_selectliste
		
		if params[ :filter ] and params[ :filter ][ :feld ] and params[ :filter ][ :text ]
			# wandle Texteingaben fuer den Filter in sinnvolle Werte
			filter_init[ :feld ] = params[ :filter ][ :feld ]
			filter_init[ :text ] = Reservation.wandle_werte( params[ :filter ][ :feld ], params[ :filter ][ :text ] )
		end
		
		session[ :reservation_filter ] = Filter.new( filter_init )
		redirect_to :action => 'list'
	end
	def loesche_filter
		session[ :reservation_filter ].text = '' # kein Suchstring
		redirect_to :action => 'list'
	end
	
#----------------------------------------------------------
# Update Operationen, gesamt und komponentenweise

  def update
		@reservation = Reservation.find( params[ :id ] )
		unless params[ :reservation ]
			# keine Reservationsparameter da, also nochmal edit und raus
			render :action => 'show'
		else

			params_res = params[ :reservation ]
			unless @reservation.valid_fuer_herausgeber_aendert?( params_res )
				# die Parameter sind nicht valide, also Datum vorbereiten
				# und nochmal edit und raus
				logger.debug( "I --- reservations con | update 0 -- nicht valide  params_res:#{params_res.to_yaml}" )
				@reservation.startdatum = Time.local(
							params_res[ 'startdatum(1i)' ].to_i,
							params_res[ 'startdatum(2i)' ].to_i,
							params_res[ 'startdatum(3i)' ].to_i )
				@reservation.enddatum = Time.local(
							params_res[ 'enddatum(1i)' ].to_i,
							params_res[ 'enddatum(2i)' ].to_i,
							params_res[ 'enddatum(3i)' ].to_i )
				render :action => 'show'
				
			else
				# Parameter sind valide, Änderung durchführen
				# entfernte Pakete aus der Reservation loeschen
				#logger.debug( "I --- reservations con | update 1 -- trotzdem im IF")
				if session[ :paket_weg_liste ]
					@reservation.updater = session[ :user ]
					for paket_id in session[ :paket_weg_liste ]
						paket = Paket.find( paket_id )
						Logeintrag.neuer_eintrag( session[ :user ], 'entfernt Paket aus Reservation', "Paket #{paket.id}, Reservation #{@reservation.id}" )
						@reservation.pakets.delete( paket )
					end
				end
				session[ :paket_weg_liste ] = nil
		
				# wenn alle Pakete entfernt wurden, Reservation löschen,
				# es sei denn, Zubehör wurde ausgeliehen
				if @reservation.pakets.size == 0 and @reservation.zubehoer.blank?
					Logeintrag.neuer_eintrag( session[ :user ], 'auto-löscht Reservation, keine Pakete mehr', "Reservation #{@reservation.id}" )
					@reservation.updater = session[ :user ]
					@reservation.destroy
					flash[ :notice ] = 'Reservation wurde gelöscht, da es keine Pakete mehr enthält'
					redirect_to :controller => 'admin', :action => 'status'
				else
		
					# auf geaenderte Pakete pruefen
					paket_params_hash = params_res[ :pakets ] || {}
					for paket_id, paket_tausch_id in paket_params_hash
						#logger.debug( "I --- reservations con | update 2 -- paket_id:#{paket_id}, paket_tausch_id:#{paket_tausch_id}")
						# wenn Paket geaendert...
						if paket_id.to_i != paket_tausch_id.to_i
							# ...und nicht schon verknuepft
							unless paket_params_hash.has_key?( paket_tausch_id )
								paket = Paket.find( paket_id.to_i )
								tausch_paket = Paket.find( paket_tausch_id.to_i )
								Logeintrag.neuer_eintrag( session[ :user ],
											'tauscht Pakete in Reservation', "P#{paket.id} -> P#{tausch_paket.id} in R#{@reservation.id}" )
								@reservation.pakets.delete( paket )
								@reservation.pakets | [ tausch_paket ]
							end
						end
					end
					params_res.delete( 'pakets' )
					#logger.debug( "I --- reservations con | update 4 -- params_res:#{params_res.to_yaml}" )
		
					# neuen Updater verknuepfen
					@reservation.updater = session[ :user ]
					#logger.debug( "I --- reservations con | update 5 -- reservation #{@reservation.to_yaml}" )
					
			    if @reservation.update_attributes( params_res )
			      #logger.debug( "I --- reservations con | update 6 -- reservation nach up #{@reservation.to_yaml}" )
						flash[ :notice ] = 'Reservation wurde geändert'
						email = LeihsMailer.deliver_benachrichtigung( @reservation ) if @reservation.user != session[ :user ]
						Logeintrag.neuer_eintrag( session[ :user ], 'ändert Reservation', "Reservation #{@reservation.id}" )
			      redirect_to :controller => 'admin', :action => 'status'
			    else
			      render :action => 'show'
			    end
			
				end			
			end
		end
  end

	def update_status
		if session[ :user ].herausgeber?
			@reservation = Reservation.find( params[ :id ] )
			@reservation.status = params[ :reservation ][ :status ]
			@reservation.updater = session[ :user ]
			@reservation.save
			
			email = LeihsMailer.deliver_benachrichtigung( @reservation
						) if @reservation.user != session[ :user ]
			Logeintrag.neuer_eintrag( session[ :user ], 'ändert Status',
						"Reservation #{@reservation.id}" )	
		end
		
		redirect_to :action => 'show', :id => @reservation.id
	end
	def update_user
		if session[ :user ].herausgeber?
			@reservation = Reservation.find( params[ :id ] )
			@neuer_user = User.find( params[ :reservation ][ :user_id ] )
			@reservation.user = @neuer_user
			@reservation.save
		
			email = LeihsMailer.deliver_benachrichtigung( @reservation
						) if @reservation.user != session[ :user ]
			Logeintrag.neuer_eintrag( session[ :user ], 'ändert Benutzer',
						"Reservation #{@reservation.id}" )
		
			render( :partial => 'edit_user', :locals => {
						:reservation => @reservation } )
		else
			render :action => 'show'
		end
	end
	def update_termin
		if session[ :user ].herausgeber?
			@reservation = Reservation.find( params[ :id ] )
			#logger.debug( "I--- reservations con | upate termin -- #{params.to_yaml}")
			@reservation.update_attributes( params[ :reservation ]
						) if @reservation.valid_fuer_herausgeber_aendert?( params[ :reservation ] )
			
			Logeintrag.neuer_eintrag( session[ :user ], 'ändert Leihzeitraum',
						"Reservation #{@reservation.id}" )
      #email = LeihsMailer.deliver_benachrichtigung( @reservation ) if @reservation.user != session[ :user ]
				
			render( :partial => 'edit_termin', :locals => {
						:reservation => @reservation } )
		else
			render :action => 'show'
		end
	end

# --- Fuer Pakete ---	
	def tausche_paket_select_remote
	  unless session[ :user ].herausgeber?
			redirect_to :action => 'show', :id => params[ :id ]
      
    else
			@reservation = Reservation.find( params[ :id ] )
			@paket = Paket.find( params[ :paket_id ] )
			@ersatzpakete = @reservation.ersatzpaket_fuer_paket( @paket )
			
			Logeintrag.neuer_eintrag( session[ :user ],
						'prueft alternative Pakete zu',
						"P#{@paket.id} in R#{@reservation.id}" )
			render :action => 'tauschselect_paket_remote', :layout => false
	  end
	end
	def tausche_paket
		unless session[ :user ].herausgeber?
			redirect_to :action => 'show', :id => params[ :id ]
			
		else
			@reservation = Reservation.find( params[ :id ] )
			@paket = Paket.find( params[ :paket_id ] )
			@ersatzpaket = Paket.find( params[ :ersatzpaket_id ] )
			
			Logeintrag.neuer_eintrag( session[ :user ],
						'tauscht Pakete in Reservation',
						"P#{@paket.id} -> P#{@ersatzpaket.id} in R#{@reservation.id}" )
			@reservation.pakets.delete( @paket )
			@reservation.pakets |= [ @ersatzpaket ]
			@reservation.save
			
			render :action => 'update_paket_liste'
		end
	end

	def loesche_paket
		unless session[ :user ].herausgeber?
			redirect_to :action => 'show', :id => params[ :id ]
		
		else
			@reservation = Reservation.find( params[ :id ] )
			@paket = Paket.find( params[ :paket_id ] )
			
			# Paket loeschen, wenn es nicht das letzte ist
			unless @reservation.pakets.size <= 1 and @reservation.zubehoer.blank?
				Logeintrag.neuer_eintrag( session[ :user ],
							'entfernt Paket aus Reservation',
							"Paket #{@paket.id}, Reservation #{@reservation.id}" )
				@reservation.pakets.delete( @paket )
				@reservation.save
			end
			
			render :action => 'update_paket_liste'
		end	
	end
	
	def zufuege_paket_select_remote
	  unless session[ :user ].herausgeber?
			redirect_to :action => 'show', :id => params[ :id ]
      
    else
			@reservation = Reservation.find( params[ :id ] )
			@zusatzpakete = @reservation.zusatzpaket_fuer( params[ :paketsuche ] )
			
			Logeintrag.neuer_eintrag( session[ :user ],
						'sucht zusätzliche Pakete für',
						"R#{@reservation.id}" )
			render :action => 'zufuege_paket_select_remote', :layout => false
	  end
	end
	def zufuege_paket
		logger.debug( "C --- reservations | zufuege paket -- #{params.to_yaml}" )
		@reservation = Reservation.find( params[ :id ] )
		@paket = Paket.find( params[ :dazu_paket_id ] )
		
		Logeintrag.neuer_eintrag( session[ :user ],
					'fuegt Paket hinzu',
					"Paket #{@paket.id} -> Reservation #{@reservation.id}" )
		@reservation.pakets |= [ @paket ]
		@reservation.updater = session[ :user ]
		@reservation.save
		render :action => 'update_paket_liste'
	end
	
  # def paket_weg
  #   session[ :paket_weg_liste ] << params[ :paket_id ].to_i unless session[ :paket_weg_liste ].include?( params[ :paket_id ].to_i )
  #   edit
  #   render :action => 'show'
  # end

# --- Fuer Zubehoer ---
  def aendere_zubehoer
		unless session[ :user ].herausgeber?
			redirect_to :action => 'show', :id => params[ :id ]
			
		else
			@reservation = Reservation.find( params[ :id ] )
			@zubehoer = Zubehoer.find( params[ :zubehoer_id ] )
			@zubehoer.attributes = params[ :zubehoer ]
			@zubehoer.save
						
			Logeintrag.neuer_eintrag( session[ :user ],
						'ändert Zubehör in Reservation',
						"Z#{@zubehoer.id} in R#{@reservation.id}" )
			@reservation.updater = session[ :user ]
			@reservation.save
			
			render :action => 'update_zubehoer_liste'
		end
  end

  def loesche_zubehoer
		unless session[ :user ].herausgeber?
			redirect_to :action => 'show', :id => params[ :id ]
		
		else
			@reservation = Reservation.find( params[ :id ] )
			@zubehoer = Zubehoer.find( params[ :zubehoer_id ] )
			
			# Zubehoer loeschen, wenn es nicht das letzte Ding in der R~ ist
			unless @reservation.zubehoer.size <= 1 and @reservation.pakets.blank?
				Logeintrag.neuer_eintrag( session[ :user ],
							'entfernt Zubehör aus Reservation',
							"Zubehör #{@zubehoer.id}, Reservation #{@reservation.id}" )
				@reservation.zubehoer.delete( @zubehoer )
				@reservation.updater = session[ :user ]
				@reservation.save
			end
			
			render :action => 'update_zubehoer_liste'
		end	
  end
  
  def zufuege_zubehoer
		logger.debug( "C --- reservations | zufuege zubehoer -- #{params.to_yaml}" )
		@reservation = Reservation.find( params[ :id ] )
		@zubehoer = Zubehoer.new( params[ :zubehoer ] )
		@zubehoer.save
		
		Logeintrag.neuer_eintrag( session[ :user ],
					'fuegt Zubehoer hinzu',
					"Zubehoer #{@zubehoer.id} -> Reservation #{@reservation.id}" )
		@reservation.zubehoer << @zubehoer
		@reservation.updater = session[ :user ]
		@reservation.save
		render :action => 'update_zubehoer_liste'
  end
  
#----------------------------------------------------------
# CRUD Operationen

	def meine
		session[ :hilfeseite ] ||= 'index'
		
		@reservations = Reservation.find_fuer_benutzer( session[ :user ].id )
		session[ :reservation_items_auf ] ||= Array.new
	end

	def edit
		show
		render :action => 'show'
	end
	
  def show
		session[ :paket_weg_liste ] ||= [ ]
    @reservation = Reservation.find( params[ :id ],
          :include => [ :user, :pakets, :geraetepark ] )
  end

  def destroy
		# kann jeder aufrufen, also muss besondere Vorsicht sein
		# Reservierende koennen nur die eigenen R loeschen
		reservation = Reservation.find( params[ :id ] )
		if reservation
			#logger.debug( "I--- reservations con | destroy -- session:#{session.to_yaml}" )
			if session[ :user ].herausgeber?
				#logger.debug( "I--- reservations con | destroy2 -- reservation:#{reservation.to_yaml}" )
				Logeintrag.neuer_eintrag( session[ :user ], 'löscht Reservation', "Reservation #{reservation.id}" )
				reservation.destroy
				flash[ :notice ] = 'Reservation wurde gelöscht'
				redirect_to :controller => 'admin',
							:action => 'status'
			
			else
				#logger.debug( "I--- reservations con | destroy3 -- reservation:#{reservation.to_yaml}" )
				if session[ :user ] == reservation.user
					Logeintrag.neuer_eintrag( session[ :user ], 'löscht Reservation', "Reservation #{reservation.id}" )
					reservation.destroy
					flash[ :notice ] = 'Reservation wurde gelöscht'
				
				else
					flash[ :notice ] = 'Reservation konnte nicht gelöscht werden'
				end
				redirect_to :controller => 'reservations',
							:action => 'meine'
			end
		
		else # keine Reservation gefunden
			flash[ :notice ] = 'Reservation konnte nicht gefunden werden'
			if session[ :user ].herausgeber?
				redirect_to :controller => 'admin',
							:action => 'status'
			else
				# weiterleiten an eine Aktion, die fuer alle funktioniert
				redirect_to :action => 'meine'
			end
		end
  end
	
end
