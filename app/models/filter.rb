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
class Filter
	
	attr_accessor :feld
	attr_accessor :text
	
	def initialize( inArgs = [ ] )
		@feld = inArgs[ :feld ] || ''
		@text = inArgs[ :text ] || ''
		setze_felder_selectliste( inArgs[ :selectliste ] )
	end
	
	def setze_felder_selectliste( in_liste = nil )
		@selectliste = in_liste || [ ]
	end
	
	def felder_selectliste
		return @selectliste
	end
	
	def felder
		liste = Array.new
		for eintrag in @selectliste
			liste |= [ eintrag.last ] if eintrag.last and eintrag.last.length > 0
		end
		return liste
	end
	
	def bedingung
		if self.text.length > 0
			vergleich = " LIKE '%#{self.text}%'"
			if self.feld == ''
				bedingung = ( felder.join( vergleich + ' OR ' ) ) + vergleich
			else
				bedingung = feld.to_s + vergleich
			end
		else
			bedingung = nil
		end
		return bedingung
	end
end
