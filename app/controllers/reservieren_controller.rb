class ReservierenController < ApplicationController
	
	include LoginSystem
	before_filter :login_required
	before_filter :keine_hilfe
	
	helper :pakets
	layout 'allgemein'

#----------------------------------------------------------
# Schritte des Reserviervorgangs
	
	def index
		redirect_to :action => 'zeitraum_auswaehlen'
	end

	def neue
		session[ :reservation_id ] = nil
		session[ :reservieren_schritt ] = 1
		@fruehestes_startdatum = Reservation.fruehestes_startdatum_von( Time.now )
		
		@reservation = Reservation.new( {
		      :status => Reservation::STATUS_ZUSAMMENSTELLEN,
					:startdatum => @fruehestes_startdatum,
					:enddatum => @fruehestes_startdatum + 1.day } )
		@user = session[ :user ]
		render :action => 'zeitraum_auswaehlen'
	end
	
	def zeitraum_auswaehlen
		paketauswahl_neu
		@fruehestes_startdatum = Reservation.fruehestes_startdatum_von( Time.now )
		@reservation = Reservation.new( params[ :reservation ] )

		if @reservation.validate_neu_res_zeitraum and ( session[ :aktiver_geraetepark ] == 1 ? @reservation.validate_avz_inventur : true )
		  logger.debug( "--- reservieren con | zeitraum festlegen -- @reservation:#{@reservation.to_yaml}" )
  		@reservation.created_at = Time.now
		  @reservation.status = Reservation::STATUS_ZUSAMMENSTELLEN
			@reservation.user = session[ :user ]
			@reservation.updater_id = session[ :user ].id
  		@reservation.prioritaet = 1
  		@reservation.geraetepark_id = session[ :aktiver_geraetepark ]
			@reservation.save
			
			session[ :reservation_id ] = @reservation.id
			Logeintrag.neuer_eintrag( @reservation.user, 'gibt Zeitraum für Ausleihe an' )
			redirect_to :action => 'pakete_auswaehlen'
			
		else # es wurde kein Zeitraum geschickt oder er ist falsch
		  logger.debug( "--- reservieren con | zeitraum festlegen -- @reservation:#{@reservation.to_yaml}" )
			render :action => 'zeitraum_auswaehlen'
		end
	end
	
	def pakete_auswaehlen
		session[ :hilfeseite ] = 'pakete_auswaehlen'
		@t_start = Time.now
		#logger.debug( "I--- reservieren con | pakete auswaehlen -- session #{session.to_yaml}" )
		session[ :reservieren_schritt ] = 2
		session[ :paket_art_auf ] ||= Array[ 'Andere Hardware' ]
		
		if session[ :reservation_id ]
			@reservation = Reservation.find( session[ :reservation_id ] )
			@reservation.pakets.clear # falls schon Pakete drin waren
			@paketauswahl = session[ :reservieren_paketauswahl ] unless session[ :reservieren_paketauswahl ].blank?
		else
			if request.post?
				@reservation = Reservation.new( params[ :reservation ] )
        @reservation.status = Reservation::STATUS_ZUSAMMENSTELLEN
				@reservation.user = session[ :user ]
			else
				redirect_to :action => 'zeitraum_auswaehlen'
			end
			paketauswahl_neu
		end
		
		@reserv_mode = true
		@pakets = Paket.find_freie_in_zeitraum(
					@reservation.startdatum,
					@reservation.enddatum,
					session[ :user ].benutzerstufe,
					session[ :aktiver_geraetepark ] )
		#logger.debug( "I--- reservieren con | pakete auswaehlen -- session #{session.to_yaml}")
	end
	
	def weitere_pakete
	  paketauswahl_neu
	  @reservation = Reservation.find( session[ :reservation_id ] )
	  if @reservation.pakets.size > 0
	    # Pakete aus der Reservation in die Paketauswahl schreiben
	    for paket in @reservation.pakets
	      session[ :reservieren_paketauswahl ] << paket.id
	    end
	    @reservation.pakets = []
	    @reservation.save
	  end
	  
	  redirect_to :action => 'pakete_auswaehlen'
	end
	
	def reservation_abschicken
		session[ :reservieren_schritt ] = 3
		# User und Reservation Daten in Variable
		@user = session[ :user ]
		@reservation = Reservation.find( session[ :reservation_id ] )
		
		# Pakete holen und verknuepfen
		if session[ :reservieren_paketauswahl ] and session[ :reservieren_paketauswahl ].size > 0
			@pakets = Paket.find( session[ :reservieren_paketauswahl ] )
			for paket in @pakets
				@reservation.pakets |= [ paket ]
			end
			@reservation.save

			Logeintrag.neuer_eintrag( session[ :user ], 'stellt Pakete für Reservation zusammen' )
		end
		
	end
	
	def reservation_eintragen
		if params[ :reservation ][ :zweck ] and params[ :reservation ][ :zweck ].size < 3
			flash[ :error ] = 'Verwendungszweck muss eingetragen werden'
			redirect_to :action => 'reservation_abschicken'
			
		else
			session[ :reservieren_schritt ] = nil
			@reservation = Reservation.find( session[ :reservation_id ] )
			@reservation.zweck = params[ :reservation ][ :zweck ]
	    @reservation.status = Reservation::STATUS_NEU
			
			unless @reservation.save
				flash[ :notice ] = 'Reservation konnte nicht in Datenbank gesichert werden'
				redirect_to :action => 'reservation_abschicken'
				
			else
				Logeintrag.neuer_eintrag( session[ :user ], 'trägt neue Reservation ein', "Reservation #{@reservation.id}" )
				paketauswahl_loeschen
				session[ :reservation_id ] = nil
			end
		end
	end
	
	def reservation_abbrechen
		paketauswahl_loeschen
		session[ :reservation_id ] = nil
		Logeintrag.neuer_eintrag( session[ :user ], 'bricht Reservationsvorgang ab' )
		redirect_to :controller => 'reservations', :action => 'meine'
	end
	
end