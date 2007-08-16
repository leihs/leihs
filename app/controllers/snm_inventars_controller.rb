require_dependency "login_system"

class SnmInventarsController < ApplicationController
	
	include LoginSystem
	before_filter :admin_required
	
	layout 'allgemein', :only => [ 'sync', 'mach_pakete' ]
	
# --- Durch scaffold erzeugt ---

	def index
	  list
	  render_action 'list'
	end

	def list
	  @snm_inventar_pages, @snm_inventars = paginate :snm_inventar, :per_page => 15
	end

	def list_att
		@snm_inventar_pages, @snm_inventars = paginate :snm_inventar,
					:conditions => [ "Inv_Abteilung = ? and rental = 'yes'", params[ :abt ] ],
					:per_page => 15
		render :action => 'list'
	end

	def show
		@snm_inventar = SnmInventar.find( params[ :id ] )
		logger.debug( "I--- snm_inventar #{@snm_inventar.to_yaml}")
	end

# --- Synchronisation mit itHelp

	def sync
		# ActiveRecords Timestamping ausschalten
		#ActiveRecord::Base.record_timestamps = false
		
		@start = params[ :start ] || 0
		@anzahl = params[ :anzahl ] || 9999
		
		@snm_inventars = SnmInventar.find( :all,
					:offset => @start,
					:limit => @anzahl )
		
		seite_text = ''
		zaehler = 0
		for inventar in @snm_inventars
			
			zaehler += 1
			seite_text += "<br/>#{zaehler}: inventar Nr.#{inventar.id} wird untersucht."
			geraet_text = ''
			
			# wenn der Eintrag schon existiert, dann ersetze diesen
			@gegenstand = Gegenstand.find_by_id( inventar.inv_nr )
			unless @gegenstand
				@gegenstand = Gegenstand.new
				@gegenstand.id = inventar.inv_nr
				geraet_text += "<br/>neuer Gegenstand angelegt"
				
				# inv_nr -> original_id
				#@gegenstand.original_id = inventar.inv_nr
			end

			
			# artikel -> modellbezeichnung
			if inventar.artikel.length > 1 and @gegenstand.modellbezeichnung != inventar.artikel
				@gegenstand.modellbezeichnung = inventar.artikel
				geraet_text += "<br/>neue Modellbezeichnung: #{@gegenstand.modellbezeichnung}"
			end
			
			# beschreibung -> kommentar
			if inventar.beschreibung and inventar.beschreibung.length > 1 and @gegenstand.kommentar != inventar.beschreibung
				# pruefe, ob der Kommentar eine Seriennummer enthält
				seriennr = extrahiere_seriennummer( inventar.beschreibung )
				if seriennr
					@gegenstand.seriennr = seriennr
					geraet_text += "<br/>neue Seriennummer: #{@gegenstand.seriennr}"
				end
				
				@gegenstand.kommentar = inventar.beschreibung
				geraet_text += "<br/>neuer Kommentar: #{@gegenstand.kommentar}"
			end
			
			
			# ... -> ausleihbar
			ausleihbar = 0
			ausleihbar = 1 unless @gegenstand.ausmusterdatum
			logger.debug( "I --- ausmusterdatum: #{@gegenstand.ausmusterdatum}" )
			if @gegenstand.ausleihbar != ausleihbar
				@gegenstand.ausleihbar = ausleihbar
				geraet_text += "<br/>neuer Ausleihstatus: #{@gegenstand.ausleihbar}"
			end
			
			# sichern!
			if geraet_text.length > 1
				@gegenstand.inventar_abteilung = 'SNM'
				@gegenstand.herausgabe_abteilung = 'SNM'
				@gegenstand.updater_id = 1 # the importer
				@gegenstand.updated_at = Time.now
				
				@gegenstand.save!
				@gegenstand.reload
				#logger.debug( "I --- gegenstand nach save #{@gegenstand.to_yaml}" )
				geraet_text += "<br/>Gegenstand ID: #{@gegenstand.id}"

				seite_text += geraet_text + "<br/><b>inventar Nr.#{@gegenstand.id}: #{@gegenstand.modellbezeichnung} wurde synchronisiert.</b><br/>"
			end

		end
		
		# ActiveRecords Timestamping anschalten
		#ActiveRecord::Base.record_timestamps = true

		@html_text = seite_text
	end

	def mach_pakete
		@gegenstands = Gegenstand.find_by_sql( "select g.* from gegenstands g left join pakets p on g.paket_id=p.id where p.id is null" )
		for gegen in @gegenstands
			gegen.update_attribute( :paket_id, nil )
		end
		
		@gegenstands = Gegenstand.find( :all, :conditions => [ "paket_id is NULL" ] )
		for gegen in @gegenstands
			paket = Paket.new( { :name => gegen.modellbezeichnung, :art => gegen.art, :ausleihbefugnis => 1, :geraetepark_id => gegen.ermittle_geraetepark_id, :created_at => Time.now, :updater_id => session[ :user ].id } )
			paket.save!
			gegen.update_attribute( 'paket_id', paket.id )
			gegen.save!
		end
		@html_text = '<p>Erfolgreich!</p>'
		@html_text += '<p>' + @gegenstands.size.to_s + ' Gegenstände in neues Paket umgewandelt</p>'
	end
	
	def extrahiere_seriennummer( in_text = nil )
		re = /s\/n/
		if in_text =~ re
			logger.debug( "I --- match! vor:#{$`}, dings:#{$&}, nach:#{$'}" )
			re_nr = /[-\.\/0-9A-Za-z]+/
			if $' =~ re_nr # ' dieses komische Dings weg
				logger.debug( "I --- match! vor:#{$`}, dings:#{$&}, nach:#{$'}" )
				return $&
			end
		end
		return false
	end
	
end
