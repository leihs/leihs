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
require 'digest/sha1'

# this model expects a certain database layout and its based on the name/login pattern. 
class User < ActiveRecord::Base

	# Constants
	BERECHTIGUNG_TEXT = [ [ 'gesperrt', -1 ], [ 'neu', 0 ], [ '', -3 ], [ 'Student', 1 ], [ 'Mitarbeiter', 2 ], [ 'speziell Befugter', 3 ], [ '', -3 ], [ 'Herausgeber', 4 ], [ 'Admin', 5 ], [ 'root', 6 ] ]
	
	# Assoziationen
	belongs_to :updater,
				:class_name => 'User',
				:foreign_key => 'updater_id'
	has_many :reservations
	has_and_belongs_to_many :berechtigungs,
				:class_name => 'Geraetepark',
				:order => 'id'
	has_many :logeintraege
	
	# Validationen
	validates_presence_of :login, :nachname, :abteilung, :email
	validates_uniqueness_of :login, :message => 'existiert schon'
	validates_length_of :login, :minimum => 5, :message => 'muss mindestens 5 Zeichen lang sein'
	validates_length_of :login, :maximum => 40, :message => 'darf nicht länger als 40 Zeichen lang sein'
	validates_confirmation_of :password, :message => 'stimmt nicht mit der Wiederholung überein'
	
	public
  # Please change the salt to something else, 
  # Every application should use a different one 
  @@salt = 'coole3wampe'
  cattr_accessor :salt
	
	# Methoden für eMail Prefix und Suffix
	def email_prefix
		return email.blank? ? '' : email.split( '@' ).first
	end
	def email_prefix=( in_text = '' )
		self.email = in_text + '@' + email_suffix
		self.email = '' if email == '@'
	end
	def email_suffix
		if email and email.split( '@' ).size > 1
			return email.split( '@' ).last
		else
			return ''
		end
	end
	def email_suffix=( in_text = '' )
		self.email = email_prefix + '@' + in_text
		self.email = '' if email == '@'
	end
	
	# Kompletten Namen des Benutzers bekommen
	def name
		t_name = ''
		t_name += self.vorname + ' ' unless self.vorname.nil?
		t_name += self.nachname unless self.nachname.nil?
	end
	def name_nachname_zuerst
		t_name = ''
		t_name += self.nachname unless self.nachname.nil?
		t_name += ', ' unless self.vorname.blank? or self.nachname.blank?
		t_name += self.vorname unless self.vorname.nil?
	end
	def vorname
		return ( super.blank? ? nil : super.capitalize )
	end
	def nachname
		return ( super.blank? ? nil : super.capitalize )
	end
	def namenskuerzel
		t_resultat = ''
		t_resultat += vorname[ 0..1 ] if vorname and vorname.length >= 2
		t_resultat += nachname[ 0..2 ] if nachname and nachname.length >= 3
		return t_resultat
	end
	
	# Bezeichnung der Berechtigungen bekommen
	def benutzerstufe_text
		return User.gib_benutzerstufe_text( benutzerstufe )
	end
	def ganze_benutzerstufe_text
		resultat = benutzerstufe_text
		if self.berechtigungs
			resultat += ' ' + self.berechtigungs.first.name
			for berechtigung in self.berechtigungs
				resultat += ', ' + berechtigung.name
			end
		end
		return resultat
	end
	def berechtigungen_text
		text = ''
		for berechtigung in berechtigungs
			text += berechtigung.name
			text += ' ' if berechtigung != berechtigungs.last
		end
		return text
	end
	def hat_berechtigung?( in_berechtigung )
		resultat = false
		for berechtigung in self.berechtigungs
			resultat = true if in_berechtigung.is_a?( Fixnum ) and berechtigung.id == in_berechtigung
			resultat = true if in_berechtigung.is_a?( String ) and berechtigung.name == in_berechtigung
		end
		return resultat
	end
	def hat_ausweis?
	  return ( self.ausweis.to_s.length > 1 )
	end
	
	def benutzer_typ
		return User.gib_benutzer_typ( self.benutzerstufe )
	end
	def gesperrt?
		return ( benutzer_typ == :gesperrt )
	end
	def reservierender?
		return ( benutzer_typ == :reservierender )
	end
	def herausgeber?
		return ( benutzer_typ == :herausgeber or benutzer_typ == :admin or benutzer_typ == :root )
	end
	def admin?
		return ( benutzer_typ == :admin or benutzer_typ == :root )
	end
	def root?
		return ( benutzer_typ == :root )
	end
	def eingeloggt?
		return ( self.login_als > 0 )
	end
	
	def verspaetung_text
		t_verspaetung = 0
		for reservation in reservations
			t_verspaetung += reservation.verspaetung unless reservation.verspaetung.blank?
		end
		if t_verspaetung > 1.day
			return ( t_verspaetung / 1.day ).to_i.to_s + " Tag(e)"
		else
			return nil
		end
	end
	
	def gib_exklusiven_geraetepark
		resultat = nil
		for geraetepark in berechtigungs
			resultat = geraetepark if geraetepark.oeffentlich.to_i == 0
		end
		resultat = berechtigungs.first unless resultat
		logger.debug( "I --- user | gib exkl geraetep -- user:#{self.to_yaml}" )
		return resultat
	end
	
	def self.select_liste( in_berechtigung = 0 )
		resultat = [ ]
		for eintrag in BERECHTIGUNG_TEXT
			resultat << eintrag if eintrag[ 1 ] <= in_berechtigung
		end
		return resultat
	end
	
#------------------------------------------------------------
# Validationen fuer spezielle Faelle

	def valid_fuer_direkte_herausgabe?
		errors.add( :nachname, 'muss eingetragen sein'
					) unless nachname and nachname.length > 1
		errors.add( :abteilung, 'muss eingetragen sein'
					) unless abteilung and abteilung.length > 1
		errors.add( :email, 'existiert schon'
					) if email and email.length > 0 and User.find_by_email( email ) and User.find_by_email( email ).id != self.id
		
		return ( errors.count == 0 )
	end
	
	def valid_generell?
		valid_fuer_direkte_herausgabe?
		errors.add( :vorname, 'muss eingetragen sein'
					) unless vorname and vorname.length > 1
		errors.add( :email, 'hat ein falsches Format'
					) unless email and email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/
		errors.add( :telefon, 'muss mindestens 4 Stellen haben'
					) unless telefon and telefon.length >= 4
		errors.add( :telefon, 'ist ungültig'
					) unless telefon =~ /\+*[0-9s]+/
 		errors.add( :postadresse, 'muss vollständig sein'
					) unless postadresse and postadresse.length > 10
		return ( errors.count == 0 )
	end
	
	def valid_fuer_update?
		valid_generell?
		errors.add( :password, 'muss mindestens 7 Zeichen lang sein'
					) unless password and ( password.length >= 7 or password.length == 0 )
		errors.add( :password, 'darf nicht länger als 40 Zeichen lang sein'
					) unless password and ( password.length <= 40 or password.length == 0 )
		return ( errors.count == 0 )
	end
	
	def valid_fuer_signup?
		valid_generell?
		errors.add( :password, 'muss mindestens 7 Zeichen lang sein'
					) unless password and ( password.length >= 7 )
		errors.add( :password, 'darf nicht länger als 40 Zeichen lang sein'
					) unless password and ( password.length <= 40 )
		return ( errors.count == 0 )
	end
	
#------------------------------------------------------------
# Spezielle FINDer

	def self.benutzerliste_mit_benutzerstufe_und_berechtigung( in_benutzerstufe = nil, in_berechtigung = nil )
		logger.debug( "I --- benutzerstufe:#{in_benutzerstufe}, berechtigung:#{in_berechtigung}" )
		t_resultat = [ ]
		if in_benutzerstufe and in_berechtigung
			@alle_user = User.find_by_sql( [ "
						SELECT * FROM users
						LEFT JOIN geraeteparks_users
							ON users.id=geraeteparks_users.user_id
						WHERE users.benutzerstufe >= ?
							AND geraeteparks_users.geraetepark_id = ?
						ORDER BY nachname", in_benutzerstufe, in_berechtigung ] )
		else
			@alle_user = User.find( :all, :order => 'nachname' )
		end
		
		for user in @alle_user
			t_resultat << [ user.name_nachname_zuerst, user.id ]
		end
		return t_resultat
	end
	
	def self.count_online
		User.count( :conditions =>'login_als > 0' )
	end
	
	def self.count_fuer_berechtigung( in_berechtigung = nil )
		if in_berechtigung
			geraetepark = Geraetepark.find( in_berechtigung )
			return geraetepark.users.size
		else
			return User.count
		end
	end
	
	def self.find_buchstaben_fuer_berechtigung( in_berechtigung = nil )
		if in_berechtigung
			geraetepark = Geraetepark.find( in_berechtigung )
			users = geraetepark.users.collect { |x| x.nachname[ 0..0 ].upcase }
			return users.uniq
		else
			user_buchstaben = self.find_by_sql( "
						SELECT LEFT(u.nachname, 1) AS buchstabe
						FROM users u 
						GROUP BY buchstabe
						ORDER BY buchstabe" )
			buchstaben = user_buchstaben.collect { |x| x.buchstabe.upcase }
			return buchstaben
		end
	end
	
	def self.find_fuer_berechtigung( in_berechtigung = nil, in_options = {} )
		if in_berechtigung
			geraetepark = Geraetepark.find( in_berechtigung )
			users = geraetepark.users.collect { |x|
						( x.nachname[ 0..0 ].upcase == in_options[ :buchstabe ] ) ? x : nil }
			return users.compact
		else
			users = User.find( :all,
						:conditions => [ "left(nachname,1) like ?", in_options[ :buchstabe ] ],
						:order => 'nachname' )
			return users
		end
	end
	
	def self.gib_benutzer_typ( in_benutzerstufe = 0 )
		case in_benutzerstufe
			when -1 then :gesperrt
			when 0 then nil
			when 1..3 then :reservierender
			when 4 then :herausgeber
			when 5 then :admin
			when 6 then :root
		end
	end
	
	def self.gib_benutzerstufe_text( in_benutzerstufe = 0 )
		resultat = ''
		for eintrag in BERECHTIGUNG_TEXT
			resultat = eintrag[ 0 ].split()[ 0 ] if eintrag[ 1 ] == in_benutzerstufe
		end
		return resultat
	end

#----------------------------------------------------------
# Loeschen eines Benutzers

	def destroy_moeglich?
		unless reservations and reservations.size > 0
			return true
		else
			return 'Benutzer ist mit einer Reservation verknüpft'
		end
	end
	
	def destroy
		if self.destroy_moeglich? == true
			super
		end
	end

#------------------------------------------------------------
# Spezielle Authentifizierungs-Methoden

	def self.aktiviere_mit_token( in_token = '' )
	# Aktiviere einen neuen Benutzer
	
		neu_user = self.find( :first, :conditions => [ "substring( password, 1, 12) = ? and benutzerstufe = 0", in_token ] )
		if neu_user
			neu_user.password = 'password'
			neu_user.password_confirmation = 'password'
			neu_user.benutzerstufe = 1
			neu_user.berechtigungs << Geraetepark.find_oeffentliche
			logger.debug( "I --- user | aktiviere mit token -- user:#{neu_user.to_yaml}")
			if neu_user.update_attribute( :benutzerstufe, 1 )
				return true
			else
				logger.debug( "I -- konnte nicht speichern")
				return false
			end
		else
			return false
		end
	end
	
	def self.authenticate( in_login, in_pass )
	# Authenticate a user.
	# Example:
	#   @user = User.authenticate('bob', 'bobpass')
	
		#logger.debug( "auth --- #{in_login.to_yaml} - #{in_pass.to_yaml}" )
		find( :first, :conditions => [ "login = :login AND password = :pass", { :login => in_login, :pass => sha1( in_pass ) } ] )
	end  

	protected

	def self.sha1(pass)
	# Apply SHA1 encryption to the supplied password. 
	# We will additionally surround the password with a salt 
	# for additional security.
	
		Digest::SHA1.hexdigest("#{salt}--#{pass}--")
	end
	
	before_create :crypt_password
  
	def crypt_password
	# Before saving the record to database we will crypt the password 
	# using SHA1. 
	# We never store the actual password in the DB.
	
		write_attribute "password", self.class.sha1(password)
	end
  
	before_update :crypt_unless_empty
  
	def crypt_unless_empty
	# If the record is updated we will check if the password is 'password'.
	# If it is so we assume that the user didn't want to change his
	# password and just reset it to the old value.
	
		if password == 'password' or password == ''      
			user = self.class.find(self.id)
			self.password = user.password
		else
			write_attribute "password", self.class.sha1(password)
		end        
	end  
  
# --------------------------------------------------------------
# Hack Methoden zur direkten Nutzung in ./script/console

  def self.alle_emails_umschreiben
    # alle Benutzer mit hgkz.net, hgkz.ch oder hmt.edu EMail Adresse
    users = User.find_by_sql('select * from users where email like "%hgkz.net%" or email like "%hgkz.ch%" or email like "%hmt.edu%"')
    
    for user in users
      new_email = user.email.scan(/(.*)@.*/)[0].to_s + "@zhdk.ch"
      logger.warn( "M --- users | alle emails umschreiben -- email:#{user.email} -> #{new_email}" )
      if user.login == user.email
        user.login = new_email
      end
      user.email = new_email
      user.password = ''
      user.save
    end
    
    # alle Benutzer mit login mit hgkz.net, hgkz.ch oder hmt.edu
    users = User.find_by_sql('select * from users where login like "%hgkz.net%" or email like "%hgkz.ch%" or email like "%hmt.edu%"')
    
    for user in users
      new_email = user.login.scan(/(.*)@.*/)[0].to_s + "@zhdk.ch"
      logger.warn( "M --- users | alle logins umschreiben -- email:#{user.login} -> #{new_email}" )
      user.login = new_email
      user.password = ''
      user.save
    end
  end

end
