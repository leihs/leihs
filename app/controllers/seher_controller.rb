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