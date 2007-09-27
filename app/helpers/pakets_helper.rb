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
module PaketsHelper
	
	def mehr_als_ein_gegenstand_im_paket?( in_paket )
		return ( in_paket.gegenstands and in_paket.gegenstands.size > 1 )
	end
	
	def hinweis_im_paket?( in_paket )
		return ( in_paket.hinweise and in_paket.hinweise.length > 1 )
	end
	
	def ausleihhinweis_im_paket_und_herausgeber?( in_paket )
		return ( user_herausgeber? and in_paket.hinweise_ausleih and in_paket.hinweise_ausleih.length > 1 )
	end
		
end
