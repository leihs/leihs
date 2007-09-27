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
class Zeitraum
	
	attr_accessor :beginn
	attr_accessor :ende
	
	def initialize( inBeginn = Time.now, inEnde = nil )
		@beginn = inBeginn
		if inEnde.nil?
			@ende = @beginn.tomorrow
		else
			@ende = inEnde
		end
	end

	def dauer()
		return @ende - @beginn
	end
	
	def dauer=( inDauer )
		@ende = @beginn + inDauer * 60
	end
	
	def to_sma()
		return 'von:' + @beginn.to_s + ' bis:' + @ende.to_s
	end
	
end
