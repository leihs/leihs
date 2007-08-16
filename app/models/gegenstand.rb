class Gegenstand < ActiveRecord::Base
	
	# Assoziationen
	belongs_to :paket
	has_one :computerdaten
	belongs_to :kaufvorgang
	belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
	
	# Validationen
	validates_presence_of :modellbezeichnung, :inventar_abteilung, :herausgabe_abteilung
	
#------------------------------------------------------------
# Feldmethoden

	def name
		original = super
		if original.nil?
			return 'kein Name'
		else
			return original
		end
	end
	
	def name_oder_modell
		if self.modellbezeichnung.nil?
			if self.name == 'kein Name'
				return 'keine Modellbezeichnung'
			else
				return self.name
			end
		else
			return self.modellbezeichnung
		end
	end
	
	def inventar_nr
		return self.original_id.blank? ? id : original_id
	end
	def inventar_nr_text
		return inventar_abteilung.to_s + inventar_nr.to_s
	end

	# Fake Methode für das Paket Edit Formular
	def neue_art
		return nil
	end
	def neue_art=( in_art = nil )
		self.art = in_art if in_art and in_art.length > 1
	end

#----------------------------------------------------------
# Loeschen eines Gegenstands

	def destroy_moeglich?
		if paket.nil?
			return true
		else
			return 'Gegenstand ist in einem Paket eingebunden'
		end
	end
	
#----------------------------------------------------------
# Hilfsprozeduren

	def attribut_existiert?( in_schluessel = '', in_wert = '' )
		return ( attribut_id and Attribut.find( :first,
					:conditions => [ "ding_nr = ? and schluessel = ? and wert = ?", attribut_id, in_schluessel, in_wert ] ) )
	end
	
	def erzeuge_attribut( in_schluessel = '', in_wert = '' )
		# pruefe, ob der Gegenstand schon zugeordnete Attribute hat
		unless attribut_id
			self.attribut_id = Attribut.finde_max_attribut_id
			save
		end

		meinAttribut = Attribut.find( :first,
					:conditions => [ "ding_nr = ? and schluessel = ?", attribut_id, in_schluessel ] )
		meinAttribut ||= Attribut.new
		
		meinAttribut.schluessel ||= in_schluessel
		meinAttribut.wert = in_wert
		meinAttribut.ding_nr = attribut_id
		meinAttribut.save
		logger.debug( "I --- meinAttribut #{meinAttribut.to_yaml}" )
	end

	def ermittle_geraetepark_id
		resultat = Geraetepark.find_by_name( 'AVZ' ).id
		park = Geraetepark.find_by_name( herausgabe_abteilung.upcase ) if herausgabe_abteilung
		resultat = park.id if park
		return resultat		
	end

#-------------------------------------------------------------
# Select Liste für Art generieren

	def self.selectliste_art
		@art_gegenstaende = Gegenstand.find_by_sql( "
					SELECT DISTINCT art
					FROM gegenstands
					WHERE art IS NOT NULL
					ORDER BY art" )
		resultat = [ ]
		for gegenstand in @art_gegenstaende
			resultat << [ gegenstand.art, gegenstand.art ]
		end
		return resultat
	end
	def self.felder_selectliste
		return [
					[ 'alle', '' ],
					[ 'itHelp Nr.', 'original_id' ],
					[ 'leihs Nr.', 'id' ],
					[ 'Bezeichnung', 'modellbezeichnung' ],
					[ 'Art', 'art' ],
					[ 'Herausgabe Abt.', 'herausgabe_abteilung' ],
					[ 'Name', 'name' ] ]
	end
	
#-------------------------------------------------------------
# Angepasste FINDer und COUNTer für Gegenstand

	def self.count_fuer_berechtigung( in_berechtigung = 0 )
		geraetepark = Geraetepark.find( in_berechtigung )
		return Gegenstand.count( :conditions => [ "length( herausgabe_abteilung ) < 1 or herausgabe_abteilung = ?", geraetepark.name ] )
	end

end
