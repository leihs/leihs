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
class Geraetepark < ActiveRecord::Base
	
	has_and_belongs_to_many :users,
				:order => 'nachname'
	has_many :pakets
	has_many :reservations
	belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
	
	def self.select_liste
		resultat = [ ]
		gruppen = Geraetepark.find( :all, :order => 'name' )
		logger.debug( "I --- gruppen:#{gruppen.to_yaml}" )
		for gruppe in gruppen
			resultat << [ gruppe.name, gruppe.id ]
		end
		return resultat
	end
	
	def self.find_oeffentliche
		return self.find_all_by_oeffentlich( 1 )
	end
end
