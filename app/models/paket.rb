class Paket < ActiveRecord::Base
	
	has_many :gegenstands
	has_and_belongs_to_many :reservations, :order => 'startdatum DESC'
	belongs_to :geraetepark
	belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
	
	STATUS_TEXT = [ [ 'ausgemustert', -2 ], [ 'nicht ausleihbar', -1 ], [ 'unvollständig', 0 ], [ 'ok (ausleihbar)', 1 ] ]
	AUSLEIHBEFUGNIS_TEXT = User::BERECHTIGUNG_TEXT

	# Direkte Validierung
	validates_associated :gegenstands
	
#-------------------------------------------------------------
# Feld Methoden

	def zeitmarke( in_marke = '0', in_vorherzeit = nil )
		t = Time.now
		logger.debug( "Z")
		logger.debug( "Z --- paket | zeitmarke -- #{in_marke}:#{t.sec}.#{(t.usec/10000).to_i}")
		logger.debug( "Z --- zeitmarke differenz:#{(t-in_vorherzeit)}" ) if in_vorherzeit.is_a?( Time )
		logger.debug( "Z")
		return t
	end

	def ausleihbefugnis_text
		resultat = User.gib_benutzerstufe_text( ausleihbefugnis )
		resultat += ' ' + geraetepark.name unless geraetepark.name == 'AVZ'
		return resultat
	end

	def ausleihbefugnis_array
		return AUSLEIHBEFUGNIS_TEXT
	end
	
	def inventar_nr
		return gegenstands.first.inventar_nr if gegenstands.size > 0
	end
	def inventar_nr_text
		resultat = ''
		resultat += gegenstands.first.inventar_nr_text if gegenstands.size > 0
		return resultat
	end
	
	def alle_inventar_nr_text
		text = ''
		for gegenstand in gegenstands
			text += gegenstand.inventar_nr_text if gegenstand.inventar_nr_text
			text += ', ' unless gegenstand == gegenstands.last
		end
		return text
	end
	
	def status_kurztext
		text = ''
		text = 'X' if status == -1
		text = 'U' if status == 0
		return text
	end
	def status_text
		for eintrag in STATUS_TEXT
			return eintrag[ 0 ] if eintrag[ 1 ] == status
		end
	end
	
	def uebersicht_text
		text = inventar_nr.to_s + ' ' + name
		return text
	end
	
	# Fake Methode für das Rücknahme Formular
	def zurueck
		return false
	end
	# Fake Methode für das Paket Edit Formular
	def neue_art
		return nil
	end
	def neue_art=( in_art = nil )
		self.art = in_art if in_art and in_art.length > 1
	end
	
#-------------------------------------------------------------
# Auswertung Methoden

	def komplett_frei?( in_startdatum, in_enddatum, in_servicetag = true )
		servicetag = ( in_servicetag ? 1.day : 0 )
komplett_status = true
		for reservation in reservations
			# wenn ein Servicetag eingehalten werden muss,
			# den Zeitraum fuer den Test ausweiten, denn zwischen den
			# Reservationen muss Luft sein
			belegt = ( reservation.fest? and reservation.im_zeitraum?( in_startdatum - servicetag, in_enddatum + servicetag ) )
			komplett_status = ( komplett_status and !belegt )
		end
		#logger.debug( "I--- F " + komplett_status.to_s )
		return komplett_status
	end
	
	def ist_am_lager?
		unless defined?( @ist_am_lager )
		  @ist_am_lager = ( reservations.detect { |r| r.ausgeliehen? } == nil )
		end
		return @ist_am_lager
	end
	
	def ueberlappt_wo( in_startdatum, in_enddatum, ausser_res_id = nil )
		ueberlappt_status = :nichts
		for reservation in reservations
			unless reservation.id == ausser_res_id
				neu_ueberlappt = reservation.ueberlappt_wo( in_startdatum, in_enddatum )
				#logger.debug( "I--- Lap #{neu_ueberlappt.to_s}" )
				case ueberlappt_status
					when :nichts
						ueberlappt_status = neu_ueberlappt
					when :vorne
						ueberlappt_status = :beides if reservation.ueberlappt_wo( in_startdatum, in_enddatum ) == :hinten
						ueberlappt_status = :alles if neu_ueberlappt == :alles
					when :hinten
						ueberlappt_status = :beides if reservation.ueberlappt_wo( in_startdatum, in_enddatum ) == :vorne
						ueberlappt_status = :alles if neu_ueberlappt == :alles
					when :mitte
						ueberlappt_status = :alles if neu_ueberlappt == :alles or neu_ueberlappt == :beides
				end
			end
		end
		#logger.debug( "I--- Lap gesamt #{ueberlappt_status.to_s}" )
		return ueberlappt_status
	end
	
	def ueberlappt_hash( in_reservation )
		der_hash = { :vorne => 'gruen', :mitte => 'gruen', :hinten => 'gruen' }
		for reservation in reservations
			#logger.debug( "I--- Lap IN(id:#{in_reservation.id}, start:#{in_reservation.startdatum}, end:#{in_reservation.enddatum} CHECK(id:#{reservation.id}, start:#{reservation.startdatum}, end:#{reservation.enddatum}" )
			unless reservation.id == in_reservation.id
				neu_ueberlappt = reservation.ueberlappt_wo( in_reservation.startdatum, in_reservation.enddatum )
				#logger.debug( "I--- neu_ueberlappt:#{neu_ueberlappt}" )
				case neu_ueberlappt
					when :vorne, :mitte, :hinten
						der_hash[ neu_ueberlappt ] = 'rot' if der_hash[ neu_ueberlappt ] != 'rot' and reservation.konkurrierend?
						der_hash[ neu_ueberlappt ] = 'gelb' if der_hash[ neu_ueberlappt ] == 'gruen' and reservation.potenziell_konkurrierend?
						#logger.debug( "I--- im Case:#{der_hash.to_yaml}" )
					when :alles
						for eins in [ :vorne, :mitte, :hinten ]
							der_hash[ eins ] = 'rot' if der_hash[ eins ] != 'rot' and reservation.konkurrierend?
							der_hash[ eins ] = 'gelb' if der_hash[ eins ] == 'gruen' and reservation.potenziell_konkurrierend?
						end
				end	
			end
		end
		return der_hash
	end
	
	def minimale_verlaengerung_datum( in_reservation, in_servicetag = true )
		# welche R~ verlaengern?
		das_datum = Time.now - 2.years # hinreichend in Vergangenheit
		servicetag = ( in_servicetag ? 1.day : 0 )
		
		for reservation in reservations
			if reservation.fest?
				unless reservation == in_reservation
					#logger.debug( "I --- res #{reservation.id} von #{reservation.startdatum.strftime( '%d.%m.%y %H:%M:%S')} bis #{reservation.enddatum.strftime( '%d.%m.%y %H:%M:%S')}" )
					#logger.debug( "I --- diese res #{in_reservation.id} von #{in_reservation.startdatum.strftime( '%d.%m.%y %H:%M:%S')} bis #{in_reservation.enddatum.strftime( '%d.%m.%y %H:%M:%S')}" )
					das_datum = reservation.enddatum + servicetag if reservation.enddatum + servicetag > das_datum and reservation.enddatum + servicetag < in_reservation.enddatum
				end
			end
		end
		return das_datum
	end
	
	def maximale_verlaengerung_datum( in_reservation, in_servicetag )
		# welche R~ verlaengern?
		das_datum = Time.now + 2.years # hinreichend in der Zukunft
		servicetag = ( in_servicetag ? 1.day : 0 )
		
		for reservation in reservations
			if reservation.fest?
				unless reservation == in_reservation
					das_datum = reservation.startdatum - servicetag if reservation.startdatum - servicetag < das_datum and reservation.startdatum - servicetag > in_reservation.startdatum
				end
			end
		end
		return das_datum
	end
	
#----------------------------------------------------------
# Loeschen eines Pakets

	def destroy_moeglich?
		unless reservations and reservations.size > 0
			return true
		else
			return 'Paket ist in einer Reservation eingebunden'
		end
	end

	def destroy
		for gegen in gegenstands
			gegen.paket = nil
			gegen.save
		end
		super
	end
	
#-------------------------------------------------------------
# speziell definierte FINDs

	def finde_konkurrierende_reservationen( in_reservation )
		# Findet aus den Reservationen des Pakets welche,
		# die zur gelieferten Reservation konkurrieren
		konkurrierende_reservationen = [ ]
		for reservation in reservations
			konkurrierende_reservationen << reservation if reservation.im_zeitraum?( in_reservation.startdatum, in_reservation.enddatum ) and reservation.potenziell_konkurrierend?
		end
		return konkurrierende_reservationen
	end
	
	def self.find_mit_befugnis_und_art_array( in_benutzerstufe = 1, in_geraetepark = 0, in_art_array = [ ] )
		# ist in in_art_array überhaupt was drin?
		if in_art_array.size > 0
			t_art_array_text = in_art_array.join( ',' )
			pakete_array = self.find( :all,
						:include => [ :reservations, :gegenstands, :geraetepark ],
						:conditions => [ "ausleihbefugnis <= ? and pakets.geraetepark_id = ? and FIND_IN_SET( art, ? )", in_benutzerstufe, in_geraetepark, t_art_array_text ],
						:order => 'pakets.art, pakets.name' )
		else
			pakete_array = self.find( :all,
						:include => [ :reservations, :gegenstands, :geraetepark ],
						:conditions => [ "ausleihbefugnis <= ? and pakets.geraetepark_id = ?", in_benutzerstufe, in_geraetepark ],
						:order => 'pakets.art, pakets.name' )
		end
		return pakete_array
	end
  
  def self.find_mit_befugnis_ohne_nicht_ausleihbare( in_benutzerstufe = 1, in_geraetepark = 0 )
    # wird verwendet für pakets/list und findet alle Pakete, egal ob gerade
    # verfügbar oder nicht. Aber ohne die, die man nicht ausleihen kann
		pakete_array = self.find( :all,
					:include => [ :reservations ],
					:conditions => [ "ausleihbefugnis <= ? and pakets.geraetepark_id = ? and pakets.status >= 1", in_benutzerstufe, in_geraetepark ],
					:order => 'pakets.art, pakets.name' )
		return pakete_array
  end
  
	def self.find_belegte_in_zeitraum( in_startdatum, in_enddatum, in_benutzerstufe = 1, in_geraetepark = 0, in_art_array = [ ] )
		# ist in in_art_array überhaupt was drin?
		if in_art_array.size > 0
			t_art_array_text = in_art_array.join( ',' )
			belegte_pakete = self.find( :all,
						:include => [ :reservations ],
						:conditions => [ "ausleihbefugnis <= ? and pakets.geraetepark_id = ? and FIND_IN_SET( art, ? )
										and reservations.startdatum <= ?
										and reservations.enddatum >= ?
										and reservations.status >= 2",
										in_benutzerstufe, in_geraetepark, t_art_array_text, in_startdatum, ( in_enddatum.at_midnight - 1.day ),  ] )
		else
			belegte_pakete = self.find( :all,
						:include => [ :reservations ],
						:conditions => [ "ausleihbefugnis <= ? and pakets.geraetepark_id = ?
										and reservations.startdatum <= ?
										and reservations.enddatum >= ?
										and reservations.status >= 2",
										in_benutzerstufe, in_geraetepark, in_startdatum, ( in_enddatum.at_midnight - 1.day ),  ] )
		end
		return belegte_pakete
		#logger.debug( "I--- paket | find belegte zeitraum:#{belegte_pakete.length.to_s}" )
	end
	
	def self.find_nicht_ausleihbare
		nicht_ausleihbare = self.find( :all,
					:conditions => "status < 0" )
		return nicht_ausleihbare
	end
	
	def self.find_freie_in_zeitraum( in_startdatum, in_enddatum,
	      in_benutzerstufe = 1, in_geraetepark = 0, in_art = nil )
		#logger.warn( 'W--- frei in zeitraum:' + in_startdatum.class.to_s )
		#logger.warn( 'W--- frei in zeitraum:' + in_startdatum.to_s )
		alle_pakete = self.find_mit_befugnis_und_art_array( in_benutzerstufe, in_geraetepark, ( in_art ? [ in_art ] : Array.new ) )
		#logger.warn( 'W--- alle_pakete:' + alle_pakete.length.to_s )
		belegte_pakete = self.find_belegte_in_zeitraum( in_startdatum, in_enddatum, in_benutzerstufe, in_geraetepark, ( in_art ? [ in_art ] : Array.new ) )
		nicht_ausleihbare_pakete = self.find_nicht_ausleihbare
		return alle_pakete - belegte_pakete - nicht_ausleihbare_pakete
	end
	
	def self.count_fuer_berechtigung( in_berechtigung = 1 )
		return Paket.count_by_sql( [ "
					SELECT count(*)
					FROM pakets
					WHERE geraetepark_id = ?", in_berechtigung ] )
	end
			
#-------------------------------------------------------------
# Select Liste für Art generieren

	def self.selectliste_art
		@art_pakete = Paket.find_by_sql( 'SELECT DISTINCT art FROM pakets ORDER BY art')
		resultat = [ ]
		for paket in @art_pakete
			resultat << [ paket.art, paket.art ] unless paket.art.blank?
		end
		return resultat
	end

end