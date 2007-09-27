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
class Seher
	
	public
	def self.test
		return 'Hier bin ich'
	end
	
# -----------------------------------------------------------------------
# Klassen Methoden fuer script/runner Zugriff

	def self.pruefe_benachrichtigungen( in_user = User.find( 1 ) )
		ueberfaellige = Reservation.find_ueberfaellige
		anz_nicht_zurueckgebracht = 0
		anz_nicht_abgeholt = 0

		for reservation in ueberfaellige
			if reservation.nicht_zurueckgebracht?
				email = LeihsMailer.deliver_mahnung_ueberfaellig( reservation )
				anz_nicht_zurueckgebracht += 1
			else
				email = LeihsMailer.deliver_mahnung_reservation( reservation )
				anz_nicht_abgeholt += 1
			end
		end

		Logeintrag.neuer_eintrag( in_user, 'prueft Benachrichtigungen', "#{anz_nicht_zurueckgebracht} Reservationen nicht zurückgebracht,\n #{anz_nicht_abgeholt} Reservationen nicht abgeholt" )
		
		return ueberfaellige
	end

end
