class Reservation < ActiveRecord::Base
	
	belongs_to :user
	has_and_belongs_to_many :pakets
	has_many :zubehoer, :dependent => :destroy
	belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
	belongs_to :herausgeber, :class_name => 'User', :foreign_key => 'herausgeber_id'
	belongs_to :zuruecknehmer, :class_name => 'User', :foreign_key => 'zuruecknehmer_id'
	belongs_to :geraetepark
	
	STATUS_TEXT = [ [ 'zurückgegeben', -2 ], [ 'abgelehnt', -1 ], [ 'neu', 0 ], [ 'vorläufig', 1 ], [ 'genehmigt', 2 ], [ 'ausgeliehen', 9 ] ]
	BEWERTUNG_TEXT = [ [ 'schlecht', -1 ], [ 'akzeptabel', 0 ], [ 'gut', 1 ] ]
	
	# Direkte Validierung
	validates_uniqueness_of :id
	validates_presence_of :startdatum, :enddatum, :on => :create
	validates_associated :user, :updater, :geraetepark
	
#-------------------------------------------------------------
# Ausgaben von Werten

	def zeitmarke( in_marke = '0', in_vorherzeit = nil )
		t = Time.now
		logger.debug( "Z")
		logger.debug( "Z --- reservation | zeitmarke -- #{in_marke}:#{t.sec}.#{(t.usec/10000).to_i}")
		logger.debug( "Z --- zeitmarke differenz:#{(t-in_vorherzeit)}" ) if in_vorherzeit.is_a?( Time )
		logger.debug( "Z")
		return t
	end

	def status_text
		text = 'unbekannt'
		for eintrag in STATUS_TEXT
			text = eintrag[ 0 ] if eintrag[ 1 ] == self.status
		end
		return text
	end

	def bewertung_text
		text = 'unbekannt'
		for eintrag in BEWERTUNG_TEXT
			text = eintrag[ 0 ] if eintrag[ 1 ] == self.bewertung
		end
		return text
	end

	def zeitraum_text
		if rueckgabedatum.nil?
			schluss_datum = enddatum
		else
			schluss_datum = rueckgabedatum
		end
		text = startdatum.strftime( '%d.' )
		text += startdatum.strftime( '%m.' ) unless startdatum.month == schluss_datum.month
		text += startdatum.strftime( '%y' ) unless startdatum.year == schluss_datum.year
		text += '-' + schluss_datum.strftime( '%d.%m.' )
		text += schluss_datum.strftime( '%y' )
		return text
	end
	
	def uebersicht_text
		text = 'unbekannt'
		text = 'Zubehör' unless zubehoer.blank?
		text = pakets.first.uebersicht_text if pakets.size > 0
		return text
	end
	
	def self.felder_selectliste
		return [
					[ 'id', 'reservations.id' ],
					[ 'Status', 'status' ],
					[ 'von', 'startdatum' ],
					[ 'bis', 'enddatum' ],
					#[ 'Kunde', 'users.nachname' ],
					[ 'Bewertung', 'bewertung' ] ]
	end
	
	def self.wandle_werte( in_feld, in_text )
		#case in_feld
			#when 'status'
		return in_text
	end

#-------------------------------------------------------------
# überschriebene Feldmethoden

	def enddatum( in_echtes = false )
		t_enddatum = ( ( rueckgabedatum.nil? or in_echtes ) ? super : rueckgabedatum )
		return t_enddatum
	end

	def verspaetung
		unless rueckgabedatum.nil?
			t_verspaetung = rueckgabedatum - enddatum( true )
			if t_verspaetung > 1.day
				return t_verspaetung
			else
				return nil
			end
		else
			return nil
		end			
	end
	
	def verspaetung_text
		return ( verspaetung / 1.day ).to_i.to_s + " Tag(e)"
	end
	
#-------------------------------------------------------------
# Auswertung Methoden und entsprechende FINDer
	
	# --- neu ---
	def neu?
		return ( status == 0 )
	end
	def self.find_neue( in_geraetepark = 1 )
		Reservation.find( :all,
					:conditions => [ 'status=0 and geraetepark_id=?', in_geraetepark ],
					:order => 'updated_at DESC' )
	end

	# --- vorläufig ---
	def vorlaeufig?
		return ( status == 1 )
	end
	def self.find_vorlaeufige( in_geraetepark = 1 )
		Reservation.find( :all,
					:conditions => [ "status = 1 and geraetepark_id = ?", in_geraetepark ],
					:order => 'updated_at DESC' )
	end

	# --- genehmigt ---
	def genehmigt?
		return ( status == 2 )
	end
	def self.find_genehmigte( in_geraetepark = 1 )
		Reservation.find( :all,
					:conditions => [ "status = 2 and geraetepark_id = ?", in_geraetepark ],
					:order => 'updated_at DESC' )
	end

	# --- abgelehnt ---
	def abgelehnt?
		return ( status == -1 )
	end
	
	# --- kommend ---
	def self.find_kommende( in_options = {} )
		in_referenzdatum = in_options[ :referenzdatum ] || Time.now
		in_referenzdatum = in_referenzdatum.at_midnight
		in_geraetepark_id = in_options[ :geraetepark_id ] || nil
		in_benutzer_id = in_options[ :benutzer_id ] || nil
		in_limit = in_options[ :limit ] || 9999
		
		bedingungen_aus = 'reservations.status > 0 and reservations.status < 9 and reservations.startdatum >= :dat_jetzt and reservations.startdatum <= :dat_bis'
		parameter = { :dat_jetzt => in_referenzdatum - KULANZ_ZEIT,
									:dat_bis => ( in_referenzdatum + VORSCHAU_ZEIT ) }
		if in_benutzer_id
			bedingungen_aus += ' and reservations.user_id = :user_id'
			parameter[ :user_id ] = in_benutzer_id
		end
		if in_geraetepark_id
			bedingungen_aus += ' and reservations.geraetepark_id = :geraetepark_id'
			parameter[ :geraetepark_id ] = in_geraetepark_id
		end
		
		ausleihen = Reservation.find( :all,
					:conditions => [ bedingungen_aus, parameter ],
					:include => [ :pakets ],
					:order => 'startdatum',
					:limit => in_limit )
					
		bedingungen_rueck = "reservations.status = 9 and reservations.enddatum >= :dat_jetzt and reservations.enddatum <= :dat_bis"
		if in_benutzer_id
			bedingungen_rueck += ' and reservations.user_id = :user_id'
		end
		if in_geraetepark_id
			bedingungen_rueck += ' and reservations.geraetepark_id = :geraetepark_id'
		end

		rueckgaben = Reservation.find( :all,
					:conditions => [ bedingungen_rueck, parameter ],
					:include => [ :pakets ],
					:order => 'enddatum',
					:limit => in_limit )
					
		kommende = ausleihen + rueckgaben
		kommende.sort! { | a, b | a.sortier_datum <=> b.sortier_datum }
		return kommende
	end

	# --- ausgeliehen ---
	def ausgeliehen?
		return ( status == 9 )
	end
	def self.find_ausgeliehene( in_geraetepark = 1 )
		Reservation.find( :all,
					:conditions => [ "reservations.status = 9 and reservations.geraetepark_id = ?", in_geraetepark ],
					:include => [ :pakets ],
					:order => 'reservations.updated_at DESC' )
	end
	
	# --- nicht abgeholt ---
	def nicht_abgeholt?( in_referenz_datum = Time.now )
		return ( status > 0 and status <= 2 and self.startdatum < ( in_referenz_datum.at_midnight ) )
	end
	def self.find_nicht_abgeholte( in_geraetepark = nil, in_referenz_datum = Time.now )
		if in_geraetepark
			return Reservation.find( :all,
						:conditions => [ "reservations.status > 0 and reservations.status <= 2 and reservations.startdatum < :dat and reservations.geraetepark_id = :berechtigung",
									{ :dat => ( in_referenz_datum.at_midnight ),
										:berechtigung => in_geraetepark } ],
						:include => [ :pakets ],
						:order => 'enddatum' )
		else
			return Reservation.find( :all,
						:conditions => [ "reservations.status > 0 and reservations.status <= 2 and reservations.startdatum < :dat",
									{ :dat => ( in_referenz_datum.at_midnight ) } ],
						:include => [ :pakets ],
						:order => 'enddatum' )
		end
	end
	
	# --- zurück ---
	def zurueck?
		return ( status == -2 )
	end
	
	# --- nicht_zurueck ---
	def nicht_zurueckgebracht?( in_referenz_datum = Time.now )
		return ( status == 9 and self.enddatum < ( in_referenz_datum.at_midnight ) )
	end
	def self.find_nicht_zurueckgebrachte( in_geraetepark = nil, in_referenz_datum = Time.now )
		if in_geraetepark
			return Reservation.find( :all,
						:conditions => [ "reservations.status = 9 and reservations.enddatum < :dat and reservations.geraetepark_id = :berechtigung",
									{ :dat => ( in_referenz_datum.at_midnight ),
										:berechtigung => in_geraetepark } ],
						:include => [ :pakets ],
						:order => 'enddatum' )
		else
			return Reservation.find( :all,
						:conditions => [ "reservations.status = 9 and reservations.enddatum < :dat",
									{ :dat => ( in_referenz_datum.at_midnight ) } ],
						:include => [ :pakets ],
						:order => 'enddatum' )
		end
	end

	# --- überfällig ---
	def ueberfaellig?
		return ( nicht_abgeholt? or nicht_zurueckgebracht? )
	end
	def self.find_ueberfaellige( in_geraetepark = nil, in_referenz_datum = Time.now )
		nicht_abgeholte = Reservation.find_nicht_abgeholte( in_geraetepark, in_referenz_datum )
		nicht_zurueckgebrachte = Reservation.find_nicht_zurueckgebrachte( in_geraetepark, in_referenz_datum )
		ueberfaellige = nicht_abgeholte + nicht_zurueckgebrachte
		ueberfaellige.sort! { | a, b | a.sortier_datum <=> b.sortier_datum }
		return ueberfaellige
	end
	
	
	def konkurrierend?
		return ( genehmigt? or ausgeliehen? )
	end
	def potenziell_konkurrierend?
		return ( konkurrierend? or neu? or vorlaeufig? )
	end
	def pakete_am_lager?
		#t1 = zeitmarke "res:#{id}.pakete am lager 1"
		status = true
		for paket in pakets
			unless paket.ist_am_lager?
				status = false 
			end
		end
		#zeitmarke "res:#{id}.pakete am lager 2", t1
		#logger.debug( "I --- reservation | pakete am lager? -- #{status}" )
		return status
	end
	
	# --- fuer spezielle Einschraenkungen ---
	def self.count_fuer_berechtigung( in_berechtigung = 1 )
		return Reservation.count( :conditions => [ "geraetepark_id = ?", in_berechtigung ] )
	end
	def self.find_fuer_benutzer( in_id = 0, in_referenz_datum = Time.now )
		# überfällige
		ueberfaellige = Reservation.find( :all,
				:conditions => [ "user_id = ? and status = 9 and enddatum < ?", in_id, ( in_referenz_datum - KULANZ_ZEIT ) ],
				:order => 'updated_at DESC' )
				
		# kommende Ausleihen
		ausleihen = Reservation.find( :all,
				:conditions => [ "user_id = :user and status > 0 and status < 9 and startdatum > :dat_jetzt and startdatum < :dat_bis",
							{ :user => in_id,
								:dat_jetzt => in_referenz_datum - KULANZ_ZEIT,
								:dat_bis => ( in_referenz_datum + VORSCHAU_ZEIT ) } ],
				:order => 'startdatum' )
				
		#kommende Rückgaben
		rueckgaben = Reservation.find( :all,
				:conditions => [ "user_id = :user and status = 9 and enddatum > :dat_jetzt and enddatum < :dat_bis",
							{ :user => in_id,
								:dat_jetzt => in_referenz_datum - KULANZ_ZEIT,
								:dat_bis => ( in_referenz_datum + VORSCHAU_ZEIT ) } ],
				:order => 'enddatum' )

		kommende = ausleihen | rueckgaben
		kommende.sort! { | a, b | a.sortier_datum <=> b.sortier_datum }
		
		# der Rest, der nicht 
		rest = Reservation.find( :all,
				:conditions => [ "user_id = ?", in_id ],
				:order => 'updated_at DESC' )
				
		alle = ueberfaellige | kommende | rest
		return alle.uniq
	end

#-------------------------------------------------------------
# Auswertung Methoden

	def fest?()
		return ( status >= 2 or status == -2 )
	end
	
	def im_zeitraum?( in_startdatum, in_enddatum )
		ist_frei = ( in_startdatum >= enddatum.at_midnight or in_enddatum <= startdatum )
		return !ist_frei
	end

	def ueberlappt_wo( in_startdatum = nil, in_enddatum = nil )
		ueberlappt_status = :nichts
		ueberlappt_status = :alles if self.startdatum <= in_startdatum and self.enddatum >= in_enddatum
		ueberlappt_status = :vorne if self.startdatum <= in_startdatum and self.enddatum > in_startdatum
		ueberlappt_status = :mitte if self.startdatum > in_startdatum and self.enddatum < in_enddatum
		ueberlappt_status = :hinten if self.startdatum < in_enddatum and self.enddatum >= in_enddatum
		return ueberlappt_status
	end
	
	def sortier_datum()
		if ausgeliehen? or zurueck?
			return enddatum
		else
			return startdatum
		end
	end
  
	def maximale_verlaengerung_datum( in_servicetag = true )
		das_datum = Time.now + 2.years # hinreichend weit in der Zukunft
		for paket in pakets
			das_datum = paket.maximale_verlaengerung_datum( self, in_servicetag ) if paket.maximale_verlaengerung_datum( self, in_servicetag ) < das_datum
		end
		#logger.debug( "I --- das_datum #{das_datum.strftime( '%d.%m.%y %H:%M:%S')}" )
		return das_datum.at_midnight
	end
	
	def minimale_verlaengerung_datum( in_servicetag = true )
		das_datum = Time.now - 2.years # weit in der Vergangenheit
		for paket in pakets
			#logger.debug( "I --- ein_datum #{paket.minimale_verlaengerung_datum( self, in_servicetag ).strftime( '%d.%m.%y %H:%M:%S')}" )
			das_datum = paket.minimale_verlaengerung_datum( self, in_servicetag ) if paket.minimale_verlaengerung_datum( self, in_servicetag ) > das_datum
		end
		#logger.debug( "I --- das_datum #{das_datum.strftime( '%d.%m.%y %H:%M:%S')}" )
		return das_datum.at_midnight
	end
	
	def mindestbenutzerstufe
		resultat = 1 # minimale Befugnis
		for paket in self.pakets
			resultat = paket.ausleihbefugnis if resultat < paket.ausleihbefugnis
		end
		return resultat
	end
	
	def ersatzpaket_fuer_paket( in_paket = nil )
		#logger.debug( "I --- art:#{in_paket.art}" )
		t_resultat = [ ]
		if in_paket
			t_pakete = Paket.find_all_by_geraetepark_id_and_art( geraetepark_id, in_paket.art, :order => 'name' )
		else
			t_pakete = Paket.find_all_by_geraetepark_id( geraetepark_id, :order => 'name' )
		end
		
		for paket in t_pakete
			if ( in_paket and in_paket.id == paket.id ) or ( paket.komplett_frei?( startdatum, enddatum ) and !pakets.include?( paket ) )
				t_name = paket.name[ 0...30 ]
				t_name += ' (' + paket.alle_inventar_nr_text + ')' if paket.alle_inventar_nr_text
				t_resultat << [ t_name, paket.id ]
			end
		end
		return t_resultat
	end
	
	def zusatzpaket_fuer( in_suchstring = '' )
		#logger.debug( "I --- art:#{in_paket.art}" )
		t_resultat = [ ]
		t_pakete = Paket.find( :all,
		      :conditions => [ "geraetepark_id = ? and name LIKE ?", geraetepark_id, '%' + in_suchstring + '%' ],
		      :order => 'name' )

		for paket in t_pakete
			if paket.komplett_frei?( startdatum, enddatum ) and !pakets.include?( paket )
				t_name = paket.name[ 0...30 ]
				t_name += ' (' + paket.alle_inventar_nr_text + ')' if paket.alle_inventar_nr_text
				t_resultat << [ t_name, paket.id ]
			end
		end
		return t_resultat	  
	end
	
	def self.fruehestes_startdatum_von( in_zeit = Time.now )
		# heute für den nächsten Tag 8 Uhr reservierbar
		return ( in_zeit.beginning_of_day + 1.day + 8.hours )
	end
	
#----------------------------------------------------------
# Loeschen einer Reservation

	def destroy_moeglich?
		unless ausgeliehen? or zurueck?
			return true
		else
			return 'Reservation muss zu statistischen Zwecken im System bleiben'
		end
	end

	def destroy
		Logeintrag.neuer_eintrag( User.find( 1 ), 'löscht Reservation', "Reservation #{id}" )
		email = LeihsMailer.deliver_benachrichtigung( self ) if user != updater
		pakets.clear
		save
		super
	end
	
#------------------------------------------------------------
# Validationen fuer spezielle Faelle

	def valid_fuer_herausgeber_aendert?( in_parameter = {} )
		# prueft die übergebenen Parameter, ob sie valide wären
		#logger.debug( "I --- reservation valid f h a -- in_parameter #{in_parameter.to_yaml}" )
		in_startdatum = Time.local(
					in_parameter[ 'startdatum(1i)' ].to_i,
					in_parameter[ 'startdatum(2i)' ].to_i,
					in_parameter[ 'startdatum(3i)' ].to_i )
		in_enddatum = Time.local(
					in_parameter[ 'enddatum(1i)' ].to_i,
					in_parameter[ 'enddatum(2i)' ].to_i,
					in_parameter[ 'enddatum(3i)' ].to_i )
		#logger.debug( "I --- reservation valid f h a -- in_startdatum #{in_startdatum.to_yaml}, in_enddatum #{in_enddatum.to_yaml}" )
		
		#logger.debug( "I --- reservation valid f h a -- in_startdatum #{in_startdatum.to_yaml} jetzt #{Time.now.at_midnight}" )
		errors.add( :startdatum, 'kann nicht in der Vergangenheit liegen'
					) if in_startdatum < Time.now.at_midnight and status < 9 # erlaubt bei schon verliehenen Paketen
		errors.add( :startdatum, 'kann nicht so weit verkürzt werden'
					) if in_startdatum < minimale_verlaengerung_datum( false ) and status >= 2 # genehmigt und mehr
		errors.add( :enddatum, 'muss nach Startdatum liegen'
					) if in_enddatum <= in_startdatum
		errors.add( :enddatum, 'kann nicht so weit verlängert werden'
					) if in_enddatum > maximale_verlaengerung_datum( false ) and status >= 2 # genehmigt und mehr
		return ( errors.count == 0 )
	end
	
	def validate_fuer_direkte_herausgabe
		errors.add( :startdatum, 'muss eingetragen sein'
					) unless startdatum.is_a?( Time )
		errors.add( :enddatum, 'muss eingetragen sein'
					) unless enddatum.is_a?( Time )
		errors.add( :enddatum, 'sollte nach Startdatum liegen'
					) unless enddatum > startdatum
		return ( errors.count == 0 )
	end
	
	def validate
		unless self.enddatum > self.startdatum
			errors.add( :enddatum, 'sollte nach Startdatum liegen' )
		end
		return ( errors.count == 0 )
	end
	
	def validate_on_update
		#logger.debug( "I --- reservation validate #{self.to_yaml}" )
		#logger.debug( "I --- enddatum #{enddatum.to_yaml}" )
		#logger.debug( "I --- maximale Verlaengerung #{maximale_verlaengerung_datum.to_yaml}" )
		errors.add( :enddatum, 'kann nicht so weit verlängert werden' ) if enddatum > maximale_verlaengerung_datum and status >= 2 # genehmigt und mehr
		#logger.debug( "I --- errors #{errors.to_yaml}" )
		#logger.debug( "I --- reservation errors #{self.to_yaml}" )
		return ( errors.count == 0 )
	end

	def validate_neu_res_zeitraum
		errors.add( :startdatum, 'sollte mindestens einen vollen Tag in der Zukunft sein'
					) if startdatum < Reservation.fruehestes_startdatum_von().beginning_of_day
		errors.add( :enddatum, 'sollte nach Abholung sein' ) if enddatum <= startdatum
		return ( errors.count == 0 )	
	end
	
	def validate_avz_inventur
	  errors.add( :startdatum, ' - Ausleihe kann nicht während AVZ Inventur liegen' ) if ( startdatum >= Time.mktime( 2007, 7, 15 ) and startdatum <= Time.mktime( 2007, 8, 31 ) ) or ( startdatum <= Time.mktime( 2007, 7, 15 ) and enddatum >= Time.mktime( 2007, 8, 31 ) )
	  errors.add( :enddatum, ' - Ausleihe kann nicht während AVZ Inventur liegen' ) if ( enddatum >= Time.mktime( 2007, 7, 15 ) and enddatum <= Time.mktime( 2007, 8, 31 ) ) or ( enddatum >= Time.mktime( 2007, 8, 31 ) and startdatum <= Time.mktime( 2007, 7, 15 ) )
		return ( errors.count == 0 )	
	end
	
#-------------------------------------------------------------
# Methode zum Klonen ohne Paketzuordnungen

	def duplikat_ohne_pakete_zubehoer
		mein_klon = self.clone
		mein_klon.pakets.clear
		mein_klon.zubehoer = nil
		return mein_klon
	end
	
	protected
	
	KULANZ_ZEIT = 12.hours
	VORSCHAU_ZEIT = 36.hours
	
end