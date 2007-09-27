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
class HwInventar < ActiveRecord::Base
	
	set_table_name 'hwInventar'
	set_primary_key 'Inv_Serienr'
	
end

HwInventar.establish_connection(
		:adapter => 'mysql',
		:host => '195.176.254.22',
		:database => 'help',
		:encoding => 'utf8',
		:username => 'magnus',
		:password => '2read.0nly!' )
		