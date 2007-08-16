require_dependency "login_system"

class HwInventarsController < ApplicationController
	
	include LoginSystem
	before_filter :admin_required
	
	layout 'allgemein', :only => [ 'sync', 'mach_pakete' ]
	
# --- Durch scaffold erzeugt ---

	def index
	  list
	  render_action 'list'
	end

	def list
	  @hw_inventar_pages, @hw_inventars = paginate :hw_inventar, :per_page => 15
	end

	def list_att
		@hw_inventar_pages, @hw_inventars = paginate :hw_inventar,
					:conditions => [ "Inv_Abteilung = ? and rental = 'yes'", params[ :abt ] ],
					:per_page => 15
		render :action => 'list'
	end

	def show
		@hw_inventar = HwInventar.find( params[ :id ] )
		logger.debug( "I--- hw_inventar #{@hw_inventar.to_yaml}")
	end

# --- Synchronisation mit itHelp

	def sync
		# ActiveRecords Timestamping ausschalten
		ActiveRecord::Base.record_timestamps = false
		
		@start = params[ :start ] || 0
		@anzahl = params[ :anzahl ] || 9999
		
		@hw_inventars = HwInventar.find( :all,
					:conditions => "rental like 'yes'",
					:offset => @start,
					:limit => @anzahl )
		
		seite_text = ''
		zaehler = 0
		for inventar in @hw_inventars
			zaehler += 1
			seite_text += "<br/>#{zaehler}: inventar Nr.#{inventar.Inv_Serienr} wird untersucht."
			geraet_text = ''
			
			#wenn der Eintrag schon existiert, dann ersetze diesen
			@gegenstand = Gegenstand.find_by_original_id( inventar.Inv_Serienr )
			unless @gegenstand
				@gegenstand = Gegenstand.new
				geraet_text += "<br/>neuer Gegenstand angelegt"
				
				#Inv_Serienr -> original_id
				@gegenstand.original_id = inventar.Inv_Serienr
			end

			
			#Art_Bezeichnung -> modellbezeichnung
			if inventar.Art_Bezeichnung.length > 1 and @gegenstand.modellbezeichnung != inventar.Art_Bezeichnung
				@gegenstand.modellbezeichnung = inventar.Art_Bezeichnung
				geraet_text += "<br/>neue Modellbezeichnung: #{@gegenstand.modellbezeichnung}"
			end
			
			# Art_Gruppe_1 als Attribut 'Kategorie' schreiben
			if inventar.Art_Gruppe_2Old_before_type_cast and !@gegenstand.attribut_existiert?( 'Kategorie', inventar.Art_Gruppe_2Old_before_type_cast )
				logger.debug( "I --- inventar.Art_grupppe_2Old #{inventar.Art_Gruppe_2Old_before_type_cast}" )
				@gegenstand.erzeuge_attribut( 'Kategorie', inventar.Art_Gruppe_2Old_before_type_cast ) 
				geraet_text += "<br/>neue Gruppe_2_Old: #{inventar.Art_Gruppe_2Old_before_type_cast}"
			end
			
			#Art_Gruppe_2 -> art
			if inventar.Art_Gruppe_2_before_type_cast and @gegenstand.art != inventar.Art_Gruppe_2_before_type_cast
				@gegenstand.art = inventar.Art_Gruppe_2_before_type_cast
				geraet_text += "<br/>neue Gruppe_2: #{@gegenstand.art}"
			end
			
			#Art_Hersteller -> hersteller
			if inventar.Art_Hersteller.length > 1 and @gegenstand.hersteller != inventar.Art_Hersteller
				@gegenstand.hersteller = inventar.Art_Hersteller
				geraet_text += "<br/>neuer Art_Hersteller: #{@gegenstand.hersteller}"
			end

			#Art_Serienr -> seriennr
			if inventar.Art_Serienr.length > 1 and @gegenstand.seriennr != inventar.Art_Serienr
				@gegenstand.seriennr = inventar.Art_Serienr
				geraet_text += "<br/>neue Art_Serienr: #{@gegenstand.seriennr}"
			end
			
			# Art_Wert siehe unten
			
			# Art_Zusatz als Attribut 'Zusatzinfo' ablegen
			if inventar.Art_Zusatz.length > 1 and !@gegenstand.attribut_existiert?( 'Zusatzinfo', inventar.Art_Zusatz )
				@gegenstand.erzeuge_attribut( 'Zusatzinfo', inventar.Art_Zusatz )
				geraet_text += "<br/>neuer Art Zusatz: #{inventar.Art_Zusatz}"
			end

			#Ausmuster_Dat -> ausmusterdatum
			if inventar.Ausmuster_Dat and inventar.Ausmuster_Dat > Date.civil( 1988, 1, 1 ) and @gegenstand.ausmusterdatum != inventar.Ausmuster_Dat
				@gegenstand.ausmusterdatum = inventar.Ausmuster_Dat
				geraet_text += "<br/>neues Ausmuster_Dat: #{@gegenstand.ausmusterdatum}"
				
				# synchronisierter Gegenstand ist ausgemustert, suche zugehöriges
				# Paket, falls verknüpft und schalte auf 'nicht ausleihbar'
				if @gegenstand.paket
					paket = @gegenstand.paket
					paket.update_attribute( :status, -1 )
					geraet_text += "<br/>Paket Nr.#{paket.id} wurde deaktiviert!"
				end
			end
						
			#Ausmuster_Grund -> ausmustergrund
			if inventar.Ausmuster_Grund.length > 1 and @gegenstand.ausmustergrund != inventar.Ausmuster_Grund
				@gegenstand.ausmustergrund = inventar.Ausmuster_Grund
				geraet_text += "<br/>neuer Ausmuster_Grund: #{@gegenstand.ausmustergrund}"
			end
			
			# Benutzer in Computerdaten.benutzer_login ablegen (siehe unten)

			# DB_geaendert_am siehe unten
			
			# DB_geandert_von
			#@gegenstand.updater_id = 1  # hier muss man sich noch was einfallen lassen, um die Personen aus itHelp rauszubekommen
			
			# DB_erstellt_am -> created_at
			if inventar.DB_erstellt_am and inventar.DB_erstellt_am > Time.gm( 1988, 1, 1 ) and @gegenstand.created_at != inventar.DB_erstellt_am
				@gegenstand.created_at = inventar.DB_erstellt_am
				geraet_text += "<br/>neues DB_erstellt_at: #{@gegenstand.created_at}"
			end
			
			# DB_erstellt_von
			# evtl. in Attribute eintragen, hier muss man sich noch was einfallen lassen, um die Personen aus itHelp rauszubekommen
			
			# Eingebaut_in als Attribut 'eingebaut in' ablegen
			if inventar.Eingebaut_in.length > 1 and !@gegenstand.attribut_existiert?( 'eingebaut in', inventar.Eingebaut_in )
				@gegenstand.erzeuge_attribut( 'eingebaut in', inventar.Eingebaut_in )
				geraet_text += "<br/>neues Eingebaut_in: #{inventar.Eingebaut_in}"
			end
			
			# Geraetename -> name
			if inventar.Geraetename.length > 1 and @gegenstand.name != inventar.Geraetename
				@gegenstand.name = inventar.Geraetename
				geraet_text += "<br/>neuer Geraetename: #{@gegenstand.name}"
			end
			
			# Inv_Abteilung -> inventar_abteilung
			if inventar.Inv_Abteilung.length > 1 and @gegenstand.inventar_abteilung != inventar.Inv_Abteilung
				@gegenstand.inventar_abteilung = inventar.Inv_Abteilung
				geraet_text += "<br/>neue Inv_Abteilung: #{@gegenstand.inventar_abteilung}"
			end
			
			# Inv_geprueft -> letzte_pruefung
			if inventar.Inv_geprueft.kind_of?( Numeric ) and inventar.Inv_geprueft > 1988 and @gegenstand.letzte_pruefung != Date.civil( inventar.Inv_geprueft )
				@gegenstand.letzte_pruefung = Date.civil( inventar.Inv_geprueft )
				geraet_text += "<br/>neues Inv_geprueft: #{@gegenstand.letzte_pruefung}"
			end
			
			# Kommentar -> kommentar
			if inventar.Kommentar.length > 1 and @gegenstand.kommentar != inventar.Kommentar
				@gegenstand.kommentar = inventar.Kommentar
				geraet_text += "<br/>neuer Kommentar: #{inventar.Kommentar}"
			end
			
			# Lief_Code siehe unten

			# Lief_Firma siehe unten

			# Lief_Rechng_Dat siehe unten

			# Lief_Rechnr_Nr siehe unten

			# Stao_Abteilung -> herausgabe_abteilung
			if inventar.Stao_Abteilung.length > 1 and @gegenstand.herausgabe_abteilung != inventar.Stao_Abteilung
				@gegenstand.herausgabe_abteilung = inventar.Stao_Abteilung
				geraet_text += "<br/>neue Stao_Abteilung: #{inventar.Stao_Abteilung}"
			end
			
			#Stao_Gebaeude -> lagerort (Teil 1)
			#Stao_Raum -> lagerort (Teil 2)
			if ( inventar.Stao_Gebaeude.length > 1 or inventar.Stao_Raum.length > 1 ) and @gegenstand.lagerort != ( inventar.Stao_Gebaeude + '-' + inventar.Stao_Raum )
				@gegenstand.lagerort = ( inventar.Stao_Gebaeude + '-' + inventar.Stao_Raum )
				geraet_text += "<br/>neues Stao_Gebäude/Stao_Raum: #{@gegenstand.lagerort}"
			end
			
			#rental -> ausleihbar
			ausleihbar = 0
			ausleihbar = 1 unless @gegenstand.ausmusterdatum
			logger.debug( "I --- ausmusterdatum: #{@gegenstand.ausmusterdatum}" )
			if @gegenstand.ausleihbar != ausleihbar
				@gegenstand.ausleihbar = ausleihbar
				geraet_text += "<br/>neuer Ausleihstatus: #{@gegenstand.ausleihbar}"
			end
			
			
			#--- Kaufvorgang ---
			
			kaufvorgang_modifiziert = false
			
			# Art_Wert in Kaufvorgang.kaufpreis ablegen
			# Einheit: Rappen, Ganzzahl
			#logger.debug( "I --- gegenstand vorher #{@gegenstand.to_yaml}")
			if inventar.Art_Wert.kind_of?( Numeric ) and inventar.Art_Wert > 0
				@gegenstand.build_kaufvorgang unless @gegenstand.kaufvorgang
				if @gegenstand.kaufvorgang.kaufpreis.to_i != ( inventar.Art_Wert * 100 ).to_i
					logger.debug( "I --- gegenstand nachher #{@gegenstand.to_yaml}")
					logger.debug( "I --- kaufvorgang #{@gegenstand.kaufvorgang.to_yaml}")
					@gegenstand.kaufvorgang.kaufpreis = inventar.Art_Wert * 100
					kaufvorgang_modifiziert = true
					geraet_text += "<br/>neuer Art_Wert: #{@gegenstand.kaufvorgang.kaufpreis}"
				end
			end
			
			# Lief_Code in Kaufvorgang.lieferant ablegen
			# Lief_Firma in Kaufvorgang.lieferant ablegen, falls vorhanden
			if inventar.Lief_Code_before_type_cast
				@gegenstand.build_kaufvorgang unless @gegenstand.kaufvorgang
				lieferant = inventar.Lief_Code_before_type_cast
				lieferant = inventar.Lief_Firma if inventar.Lief_Firma.length > 1
				if @gegenstand.kaufvorgang.lieferant.to_s != lieferant
					logger.debug( "I --- Lief_Code #{inventar.Lief_Code_before_type_cast.to_yaml}(#{inventar.Lief_Code_before_type_cast.class}), vorher #{@gegenstand.kaufvorgang.lieferant.to_yaml}(#{@gegenstand.kaufvorgang.lieferant.class})" )
					@gegenstand.kaufvorgang.lieferant = lieferant
					kaufvorgang_modifiziert = true
					geraet_text += "<br/>neuer Lief_Code oder Lief_Firma: #{@gegenstand.kaufvorgang.lieferant}"
				end
			end

			# Lief_Rechng_Dat in Kaufvorgang.kaufdatum ablegen
			if inventar.Lief_Rechng_Dat.kind_of?( Comparable ) and inventar.Lief_Rechng_Dat > Date.civil( 1988, 1, 1 ) and @gegenstand.kaufvorgang and @gegenstand.kaufvorgang.kaufdatum != inventar.Lief_Rechng_Dat
				@gegenstand.build_kaufvorgang unless @gegenstand.kaufvorgang
				@gegenstand.kaufvorgang.kaufdatum = inventar.Lief_Rechng_Dat
				kaufvorgang_modifiziert = true
				geraet_text += "<br/>neues Lief_Rechng_Dat: #{@gegenstand.kaufvorgang.kaufdatum}"
			end

			# Lief_Rechnr_Nr in Kaufvorgang.rechnungsnr ablegen
			if inventar.Lief_Rechng_Nr.length > 1 and @gegenstand.kaufvorgang and @gegenstand.kaufvorgang.rechnungsnr != inventar.Lief_Rechng_Nr
				@gegenstand.build_kaufvorgang unless @gegenstand.kaufvorgang
				@gegenstand.kaufvorgang.rechnungsnr = inventar.Lief_Rechng_Nr
				kaufvorgang_modifiziert = true
				geraet_text += "<br/>neue Lief_Rechng_Nr: #{@gegenstand.kaufvorgang.rechnungsnr}"
			end


			# eventuell Kaufvorgang sichern
			if kaufvorgang_modifiziert
				@gegenstand.kaufvorgang.art ||= 'Anschaffung'
				@gegenstand.kaufvorgang.updater_id ||= 1
				@gegenstand.kaufvorgang.save!
				@gegenstand.kaufvorgang_id = @gegenstand.kaufvorgang.id
				geraet_text += "<br/>Kaufvorgang ID: #{@gegenstand.kaufvorgang.id}"
			end
			
			# --- Computerdaten ---
			
			computerdaten_modifiziert = false
			
			# Benutzer in Computerdaten.benutzer_login ablegen
			if inventar.Benutzer.length > 1 and @gegenstand.computerdaten and @gegenstand.computerdaten.benutzer_login != inventar.Benutzer
				@gegenstand.build_computerdaten unless @gegenstand.computerdaten
				@gegenstand.computerdaten.benutzer_login = inventar.Benutzer
				computerdaten_modifiziert = true
				geraet_text += "<br/>neuer Benutzer: #{@gegenstand.computerdaten.benutzer}"
			end

			# eventuell Computerdaten sichern
			if computerdaten_modifiziert
				@gegenstand.computerdaten.updater_id = 1 if @gegenstand.computerdaten.updater_id.nil? or @gegenstand.computerdaten.updater_id < 1
				@gegenstand.computerdaten.save!
				@gegenstand.computerdaten_id = @gegenstand.computerdaten.id
				geraet_text += "<br/>Computerdaten ID: #{@gegenstand.computerdaten.id}"
			end
			
			if geraet_text.length > 1
				@gegenstand.updated_at = inventar.DB_geaendert_am
				@gegenstand.save!
				logger.debug( "I --- gegenstand nach save #{@gegenstand.to_yaml}" )
				geraet_text += "<br/>Gegenstand ID: #{@gegenstand.id}"

				seite_text += geraet_text + "<br/><b>inventar Nr.#{@gegenstand.original_id}: #{@gegenstand.modellbezeichnung} wurde synchronisiert.</b><br/>"
			end

		end
		
		# ActiveRecords Timestamping anschalten
		ActiveRecord::Base.record_timestamps = true

		Logeintrag.neuer_eintrag( session[ :user ], 'hat Synchronisation ausgelöst' )
		@html_text = seite_text
	end

	def mach_pakete
		# Alle Gegenstände, die ein nicht existierendes Paket linken, nullen
		@gegenstands = Gegenstand.find_by_sql( "select g.* from gegenstands g left join pakets p on g.paket_id=p.id where g.paket_id is not null and p.id is null" )
		for gegen in @gegenstands
			gegen.update_attribute( :paket_id, nil )
		end
		
		# Nach unverknüpften Paketen der Berechtigung schauen
		geraetepark = Geraetepark.find( session[ :aktiver_geraetepark ] )
		@gegenstands = Gegenstand.find( :all, :conditions => [ "paket_id is NULL and gegenstands.herausgabe_abteilung = ?", geraetepark.name ] )
		
		for gegen in @gegenstands
			paket = Paket.new( { :name => gegen.modellbezeichnung, :art => gegen.art, :ausleihbefugnis => 1, :geraetepark_id => gegen.ermittle_geraetepark_id, :created_at => Time.now, :updater_id => session[ :user ].id } )
			paket.save!
			gegen.update_attribute( 'paket_id', paket.id )
			gegen.save!
		end
		
		Logeintrag.neuer_eintrag( session[ :user ], 'hat Paketerzeugung ausgelöst', "#{@gegenstands.size.to_s} neue Pakete" )
		@html_text = '<p>Erfolgreich!</p>'
		@html_text += '<p>' + @gegenstands.size.to_s + ' Gegenstände in neues Paket umgewandelt</p>'
	end
	
end
