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
class Logeintrag < ActiveRecord::Base
	
	belongs_to :user
	
	def self.neuer_eintrag( in_user = User.new, in_aktion = 'unbekannt', in_kommentar = nil )
		neueintrag = new( { :created_at => Time.now, :user => in_user, :aktion => in_aktion, :kommentar => in_kommentar } )
		neueintrag.save
	end
	
	def self.letzte_tage_liste( in_anzahl_tage = 10 )
		letzte_tage = self.find_by_sql( "select date_format( created_at, '%Y-%m-%d' ) as tag from logeintraege group by tag order by created_at desc limit #{in_anzahl_tage}" )
		tage_liste = []
		for tage in letzte_tage
			tage_liste << ( tage.tag.to_date )
		end
		return tage_liste
	end
	
end
