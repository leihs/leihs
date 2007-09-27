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
class Attribut < ActiveRecord::Base
	
	def self.finde_max_attribut_id
		resultats = Attribut.find_by_sql( 'SELECT max( ding_nr ) AS max FROM attributs' )
		#logger.warn( ">>-- Attribut_id:#{resultats.first.type}" )
		if resultats.first.max.nil?
			return 1
		else
			return resultats.first.max.to_i + 1
		end
	end 

end
