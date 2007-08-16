class AdminController < ApplicationController
	
	include LoginSystem
	before_filter :herausgeber_required
	before_filter :admin_required, :only => [ 'user_werden' ]

	layout 'allgemein'

	def zeitmarke( in_marke = '0' )
		logger.debug( "Z --- admin con | zeitmarke -- #{in_marke}:#{Time.now.sec}.#{(Time.now.usec/1000).to_i}")
		logger.debug( "Z")
	end
	
	def index
		redirect_to :action => 'status'
	end
	
	def status
		@t_start = Time.now
		session[ :hilfeseite ] = 'admin_status'
		status_zaehlen
		zeitmarke 1
		@reservationen_neu = Reservation.find_neue( session[ :aktiver_geraetepark ] )
		@reservationen_kommend = Reservation.find_kommende( :geraetepark_id => session[ :aktiver_geraetepark ] )
		zeitmarke 2
		@reservationen_vorlaeufig = Reservation.find_vorlaeufige( session[ :aktiver_geraetepark ] )
		zeitmarke 3
		@reservationen_ueberfaellig = Reservation.find_ueberfaellige( session[ :aktiver_geraetepark ] )
		zeitmarke 4
		@reservationen_ausgeliehen = Reservation.find_ausgeliehene( session[ :aktiver_geraetepark ] )
		zeitmarke 5
		@pakete_ausgeliehen_anzahl = 0
		@reservationen_ausgeliehen.each { | r | @pakete_ausgeliehen_anzahl += r.pakets.size if r.pakets }
		zeitmarke 6
		@reservationen_aktiv_anzahl = @reservationen_neu.size + @reservationen_kommend.size + @reservationen_ueberfaellig.size + @reservationen_vorlaeufig.size
		
		session[ :reservation_art_auf ] ||= Array.new
		session[ :reservation_items_auf ] ||= Array.new
	end
	
	def manage
		keine_hilfe
	end
	
	def schalte_hilfe
		if session[ :hilfe_aus ]
			session[ :hilfe_aus ] = nil
		else
			session[ :hilfe_aus ] = true
		end
		redirect_to :action => 'status'
	end
	
	def status_zaehlen
		@reservationen_anzahl = Reservation.count_fuer_berechtigung( session[ :aktiver_geraetepark ] )
		@pakete_anzahl = Paket.count_fuer_berechtigung( session[ :aktiver_geraetepark ] )
		@user_anzahl = User.count
		@user_online_anzahl = User.count_online
		@gegenstaende_anzahl = Gegenstand.count_fuer_berechtigung( session[ :aktiver_geraetepark ] )
	end
	
# ------------------------------------------------
# Admin Funktionen fuer speziellen Test

	def werde_user
		user = User.find( params[ :id ] )
		Logeintrag.neuer_eintrag( session[ :user ], 'wechselt Identität',
					"#{user.name}" )
		
		session[ :user ] = user
		redirect_to :controller => 'reservations', :action => 'meine'
	end
	
end
