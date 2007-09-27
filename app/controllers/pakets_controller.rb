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
require_dependency "login_system"

class PaketsController < ApplicationController
	
	include LoginSystem
	before_filter :admin_required, :except => [ 'index', 'list', 'list_unvollstaendig', 'list_nichtausleih', 'art_einblenden', 'art_ausblenden', 'alle_schliessen', 'show', 'zeige_reservationen' ]
	
	layout 'allgemein'

#----------------------------------------------------------
# Alles was fuer das auflisten gebraucht wird
	
	def index
		list
		render_action 'list'
	end
	
	def list_vorbereiten
		logger.debug( "I --- session: #{session.to_yaml}")
		session[ :hilfeseite ] ||= 'nix'
		session[ :paket_art_auf ] ||= Array[ 'Andere Hardware' ]
		
		@reserv_mode = false
		@edit_mode = false
		@befugnis = 1
		@gruppe = 1
		if session[ :user ]
			benutzerstufe = session[ :user ].benutzerstufe 
			berechtigung = session[ :aktiver_geraetepark ]
			@edit_mode = session[ :user ].admin? if session[ :user ]
		end
		@pakets = Paket.find_mit_befugnis_ohne_nicht_ausleihbare( benutzerstufe, berechtigung )
	end
	
	def list
		@t_start = Time.now
		list_vorbereiten
	end
	
	def list_unvollstaendig
		list_vorbereiten
		@keine_kategorien = true
		@pakets = Paket.find_all_by_status( 0 ) || [ ]
	end
	def list_nichtausleih
		list_vorbereiten
		@keine_kategorien = true
		@pakets = Paket.find_all_by_status( -1 ) || [ ]
	end
	def list_am_lager
		list_vorbereiten
		@keine_kategorien = true
		
		@alle_pakete = Paket.find( :all,
					:include => 'reservations',
					:conditions => [ 'pakets.geraetepark_id = ?', session[ :aktiver_geraetepark ] ],
					:order => 'pakets.id' )
					
		@pakets = [ ]
		for paket in @alle_pakete
			#logger.debug( "I --- paket con | list_am_lager -- id:#{paket.id}-#{am_lager ? 'L' : 'x'}" )
			@pakets << paket if paket.ist_am_lager?
		end
		@pakets.sort! { |a, b|
			a.inventar_nr <=> b.inventar_nr }
	end

	def list_pakete_von_art
		session[ :hilfeseite ] ||= 'nix'
		session[ :paket_art_auf ] ||= Array[ 'Andere Hardware' ]

		art = params[ :id ]
		@reservation = Reservation.find( session[ :reservation_id ] )
		@user = @reservation.user
		@reserv_mode = true
		
		pakete = Paket.find_freie_in_zeitraum(
					@reservation.startdatum,
					@reservation.enddatum,
					@reservation.user.benutzerstufe,
					session[ :aktiver_geraetepark ], art )
		render( :partial => 'pakets/list_art_pakete',
					:locals => { :pakete => pakete, :mit_inhalt => 'true' } )
	end
	
	def anzeigen
		session[ :ausgewaehlte_pakete ] = Array.new if session[ :ausgewaehlte_pakete ].nil?
		paket_ids = session[ :ausgewaehlte_pakete ]
		@pakete = Paket.find( :all, :order => 'art' )
		@ausgewaehlte_pakete = Array.new
		@andere_pakete = Array.new
		for paket in @pakete
			if paket_ids.kind_of?( Array )
				if paket_ids.include?( paket.id )
					@ausgewaehlte_pakete << paket
				else
					@andere_pakete << paket
				end
			else
				@andere_pakete << paket
			end
		end
	end

	def auswaehlen
		paket_ids = session[ :ausgewaehlte_pakete ]
		if paket_ids.kind_of?( Array )
			if paket_ids.delete( params[ :id ].to_i ).nil?
				paket_ids << params[ :id ].to_i
			end
			session[ :ausgewaehlte_pakete ] = paket_ids
		else
			session[ :ausgewaehlte_pakete ] = Array.new
		end
		
		anzeigen
		render_action 'anzeigen'
	end
	
	def zeige_reservationen
		@paket = Paket.find( params[ :id ], :include => 'reservations', :order => 'reservations.startdatum' )
	end
	
	def search_for_list
		logger.debug( "I --- pakets con | search for list -- params:#{params.to_yaml}" )
		logger.debug( "I --- pakets con | search for list -- suchstring:#{params[ :paketsuche ].to_i}" )
		t_suchquery = "pakets.name like :suchstring"
		#t_suchquery += " or gegenstands.original_id like :suchstring" if params[ :paketsuche ] != "0" and params[ :paketsuche ].to_i > 0		

		@pakets = Paket.find( :all,
					:include => 'gegenstands',
					:conditions => [ t_suchquery, {
								:suchstring => '%' + params[ :paketsuche ].to_s + '%' } ],
					:order => 'pakets.name',
					:limit => 20 )
		@reservation = Reservation.find( params[ :reservation_id ] )
		
		@pakets.delete_if { |x|
					!( x.komplett_frei?( @reservation.startdatum, @reservation.enddatum, false ) ) }
		if @pakets.size > 0
			render :partial => 'suchresultate'
		else
			render :text => "<?xml version='1.0' encoding='utf-8'?>"
		end
	end
	
	def select_for_list
		# nur als remote function aufrufbar
		@paket = Paket.find( params[ :id ] )
		render :partial => 'suchresultat_anzeige'
	end
	
# ---------------------------------------------------------
# Steuerung der Anzeigeform

	def art_einblenden
		session[ :paket_art_auf ] << ( params[ :art ] || params[ :id ] )
		session[ :paket_art_auf ].delete_at( 0 ) if session[ :paket_art_auf ].size > 3
		redirect_to :action => 'list'
	end
	def art_ausblenden
		session[ :paket_art_auf ].delete( ( params[ :art ] || params[ :id ] ) )
		redirect_to :action => 'list'
	end
	def alle_schliessen
		session[ :paket_art_auf ] = nil
		redirect_to :action => 'list'
	end

#----------------------------------------------------------
# CRUD Operationen
	
	def paket_binden #admin
		# es wurden Gegenstaende ausgewaehlt, die zu einem Paket
		# zusammengefasst werden sollen. Weitere Parameter eingeben
		session[ :hilfeseite ] = 'paket_felder'
		@paket = Paket.new
		@gegenstaende_in_sammlung = Array.new
		
		if session[ :gegenstands_auswahl ].kind_of?( Array )
			@gegenstaende_in_sammlung = Gegenstand.find( session[ :gegenstands_auswahl ] )
			if @gegenstaende_in_sammlung.length > 0
				gegenstand = @gegenstaende_in_sammlung.first
				@paket.name = gegenstand.modellbezeichnung
				@paket.art = gegenstand.art
				@paket.ausleihbefugnis = 1
				@paket.geraetepark = Geraetepark.find_by_name( gegenstand.herausgabe_abteilung ) if gegenstand.herausgabe_abteilung and gegenstand.herausgabe_abteilung.length > 0
				@paket.hinweise = gegenstand.kommentar
			end
		end
		
		render :action => 'new'
	end
	def create
		@paket = Paket.new( params[ :paket ] )
		logger.debug( "I --- paket --- create --- paket:#{@paket.to_yaml}")
		#@paket.updater = session[ :user ]
		
		@gegenstands = Array.new
		if session[ :gegenstands_auswahl ].kind_of?( Array )
			@gegenstands = Gegenstand.find( session[ :gegenstands_auswahl ] )
		end
		for gegenstand in @gegenstands
			@paket.gegenstands << gegenstand
		end
		
		if @paket.save
			flash[ :notice ] = 'Paket wurde neu angelegt'
			session[ :gegenstands_mit_sammlung ] = nil
			session[ :gegenstands_auswahl ] = nil
			redirect_to :action => 'list'
		else
			logger.debug( "I --- paket --- create --- nicht save, paket:#{@paket.to_yaml}")
			flash[ :notice ] = 'Paket konnte nicht angelegt werden'
			redirect_to :action => 'paket_binden'
		end
	end
	def show
		session[ :hilfeseite ] = 'paket_felder'
		@paket = Paket.find( params[ :id ] )
		#@gegenstaende_in_sammlung = @paket.gegenstands
	end
	def edit
		show
	end
	def update
		neue_params = params[ :paket ]
		neue_params[ :updater ] = session[ :user ]
		
		@paket = Paket.find( params[ :id ] )
		if @paket.update_attributes( params[ :paket ] )
	    flash[ :notice ] = 'Paket wurde geaendert.'
	    redirect_to :action => 'list'
	  else
	    render_action 'edit'
	  end
	end
	def destroy
		@paket = Paket.find( params[ :id ] )
		fehlermeldung = @paket.destroy_moeglich?
		if fehlermeldung == true
			@paket.destroy
		else
			flash[ :notice ] = fehlermeldung
		end
		redirect_to :action => 'list'
	end

end
