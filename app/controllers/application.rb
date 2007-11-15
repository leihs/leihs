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

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

require_dependency 'login_system'
#require_dependency 'hilfesys'

class ApplicationController < ActionController::Base
	
  include ExceptionNotifiable
	include LoginSystem
	
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_leihs_session_id'
  
  # Kann in einem Controller mit folgender Anweisung umgangen werden:
  # skip_before_filter :filter_name 
  before_filter :set_charset
	before_filter :logo_laden
	
	# --- before Filter ---
  
  # Sets default character set to UTF-8
  def set_charset
    if request.xhr?
      headers["Content-Type"] = "text/javascript; charset=utf-8" 
    else
      headers["Content-Type"] = "text/html; charset=utf-8" 
    end
  end
	def logo_laden
		#headers[ 'Cache-Control' ] = 'max-age=0'
		#headers[ 'Vary' ] = '*'
		session[ :aktiver_geraetepark ] ||= 1
		gruppe = Geraetepark.find( session[ :aktiver_geraetepark ] )
		@logo_url = gruppe.logo_url
		@logo_kontakt_text = gruppe.ansprechpartner
	end

#----------------------------------------------------------
# allgemeine Methoden
 
	def keine_hilfe
	  # Schaltet die Hilfeanzeige in der dritten Spalte aus
		session[ :hilfeseite ] = 'nix'
	end

#----------------------------------------------------------
# Funktionen für die Zusammenstellung der Paketliste
# (fuer reservieren und ausleihen)

	def paketauswahl_neu
		session[ :reservieren_sammlung ] = true
		session[ :reservieren_paketauswahl ] = Array.new
	end
	def paketauswahl_loeschen
		session[ :reservieren_sammlung ] = nil
		session[ :reservieren_paketauswahl ] = nil
	end
	def paket_dazu
		unless session[ :reservieren_paketauswahl ].nil?
			session[ :reservieren_paketauswahl ] |= [ params[ :id ].to_i ]
		end
		render( :partial => 'gemeinsam/reservieren_paketauswahl', :locals => {
					:paketauswahl => session[ :reservieren_paketauswahl ] } )
	end
	def paket_weg
		if session[ :reservieren_paketauswahl ].kind_of?( Array )
			session[ :reservieren_paketauswahl ].delete( params[ :id ].to_i )
		end
		render( :partial => 'gemeinsam/reservieren_paketauswahl', :locals => {
					:paketauswahl => session[ :reservieren_paketauswahl ] } )
	end

# ---------------------------------------------------------
# Steuerung der Anzeigeform
# (fuer reservieren und ausleihen)

	def art_einblenden
		art = params[ :art ] || params[ :id ]
		logger.debug( "I --- app | art einblenden -- art:#{art}" )
		@reservation = Reservation.find( session[ :reservation_id ] )
		@user = @reservation.user
		@reserv_mode = true
		
		session[ :paket_art_auf ] |= [ art ]
		session[ :paket_art_auf ].delete_at( 0 ) if session[ :paket_art_auf ].size > 3
		
		pakete = Paket.find_freie_in_zeitraum(
					@reservation.startdatum,
					@reservation.enddatum,
					session[ :user ].benutzerstufe,
					session[ :aktiver_geraetepark ],
					art )
		render( :partial => 'pakets/list_art_pakete',
					:locals => { :pakete => pakete, :mit_inhalt => 'true' } )
	end
	def art_ausblenden
		session[ :paket_art_auf ].delete( params[ :id ] )
		redirect_to :action => 'pakete_auswaehlen'
	end
	
	def alle_schliessen
		session[ :paket_art_auf ] = nil
		redirect_to :action => 'pakete_auswaehlen'
	end

	def umlaute_ersetzen( in_text = '' )
		if in_text.blank?
			return ''
		else
      require 'iconv'
      ic = Iconv.new('iso-8859-1','utf-8')
      text = ic.iconv(in_text)
			return text
		end
	end
	
end
