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
class SeherController < ApplicationController
	
	include LoginSystem
	before_filter :admin_required

	layout 'allgemein'
	
	def list
		if params[ :zeitspanne ].nil?
			@zeitspanne = 60 * 60
		else
			@zeitspanne = params[ :zeitspanne ][ :to_i ].to_i # kleiner Hack
		end
		@gegenstands = Gegenstand.find( :all, :conditions => [ "updated_at > ?", ( Time.now - @zeitspanne ) ], :order => 'updated_at DESC' )
		@kaufvorgangs = Kaufvorgang.find( :all, :conditions => [ "updated_at > ?", ( Time.now - @zeitspanne ) ], :order => 'updated_at DESC' )
		@computerdatens = Computerdaten.find( :all, :conditions => [ "updated_at > ?", ( Time.now - @zeitspanne ) ], :order => 'updated_at DESC' )
		@attributs = Attribut.find( :all, :conditions => [ "updated_at > ?", ( Time.now - @zeitspanne ) ], :order => 'updated_at DESC' )
		@pakets = Paket.find( :all, :conditions => [ "updated_at > ?", ( Time.now - @zeitspanne ) ], :order => 'updated_at DESC' )
		@reservations = Reservation.find( :all, :conditions => [ "updated_at > ?", ( Time.now - @zeitspanne ) ], :order => 'updated_at DESC' )
		@users = User.find( :all, :conditions => [ "updated_at > ?", ( Time.now - @zeitspanne ) ], :order => 'updated_at DESC' )
	end
	
	def pruefe_benachrichtigungen
		@ueberfaellige = Seher.pruefe_benachrichtigungen( session[ :user ] )
	end
	
end