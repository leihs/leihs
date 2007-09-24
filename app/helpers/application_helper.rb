# The methods added to this helper will be available to all templates in the application.
module ApplicationHelper
	
	def zeitmarke( in_marke = '0', in_vorherzeit = nil )
		t = Time.now
		logger.debug( "Z")
		logger.debug( "Z --- zeitmarke -- #{in_marke}:#{t.sec}.#{(t.usec/10000).to_i}")
		logger.debug( "Z --- zeitmarke differenz:#{(t-in_vorherzeit)}" ) if in_vorherzeit.is_a?( Time )
		logger.debug( "Z")
		return ( in_vorherzeit.is_a?( Time ) ? ( t - in_vorherzeit ) : t )
	end
	
	def show_icon( name )
		img_options = { 'src' => name.include?("/") ? name : "/images/#{name}" }
		img_options[ 'src' ] = img_options[ 'src' ] + ".png" unless img_options[ 'src' ].include?( "." )
		img_options[ 'class' ] = "icon"
		tag( 'img', img_options )
	end

	def ein_aus_klapp_icon( in_bild_zu, in_titel_zu, in_bild_auf, in_titel_auf, in_einausblender_prefix, in_id )
		html = link_to_function(
					image_tag( in_bild_zu,
								:class => 'icon',
								:title => in_titel_zu ),
					"Element.toggle( 'zu_#{in_id}', 'auf_#{in_id}',
								'#{in_einausblender_prefix}#{in_id}' )",
					:id => "zu_#{in_id}" )
		html += link_to_function(
					image_tag( in_bild_auf,
								:class => 'icon',
								:title => in_titel_auf ),
					"Element.toggle( 'zu_#{in_id}', 'auf_#{in_id}',
								'#{in_einausblender_prefix}#{in_id}' )",
					:id => "auf_#{in_id}",
					:style => "display:none;" )
		return html
	end

	def gib_paket_sammlung
		session[ :paket_sammlung ] ||= PaketSammlung.new()
	end
	
	def umlaute_ersetzen( in_text )
		text = in_text.gsub( 'Ä', 'Ae' )
		text.gsub!( 'Ö', 'Oe' )
		text.gsub!( 'Ü', 'Ue' )
		text.gsub!( 'ä', 'ae' )
		text.gsub!( 'ö', 'oe' )
		text.gsub!( 'ü', 'ue' )
		text.gsub!( 'ß', 'ss' )
		return text
	end
	
	def wandle_zu_html( in_text )
		html_text = in_text.gsub( /ä/, '&auml;' )
		html_text.gsub!( /ö/, '&ouml;' )
		html_text.gsub!( /ü/, '&uuml;' )
		html_text.gsub!( /Ä/, '&Auml;' )
		html_text.gsub!( /Ö/, '&Ouml;' )
		html_text.gsub!( /Ü/, '&Uuml;' )
		html_text.gsub!( /ß/, '&szlig;' )
		html_text.gsub!( /'/, '&acute;' )
		html_text.gsub!( /"/, '&quot;' )
		return html_text
	end
	
	def wandle_fuer_html_id( in_text )
		id_text = umlaute_ersetzen( in_text.downcase )
		id_text.gsub!( '/', '_' )
		id_text.gsub!( ' ', '' )
		return id_text
	end
	
	def zeige_aktions_icons( in_welche, in_id, in_optionen = { :controller => params[ :controller ] } )
		html = ''
		html += link_to(
							image_tag( "icon_stift.png", :class => 'icon' ),
							{ :controller => in_optionen[ :controller ],
								:action => 'edit',
								:id => in_id },
							:title => 'ändern'
										) if in_welche.include?( :edit )
		html += link_to(
							image_tag( "icon_kreuz.png", :class => 'icon' ),
							{ :controller => in_optionen[ :controller ],
								:action => 'destroy',
								:id => in_id },
							:title => 'löschen',
							:confirm => 'Wollen sie diesen Eintrag wirklich permanent löschen? Diese Aktion kann nicht rückgängig gemacht werden'
										) if in_welche.include?( :destroy )
		html += link_to(
							image_tag( "icon_doc.png", :class => 'icon' ),
							{ :controller => in_optionen[ :controller ],
								:action => 'show',
								:id => in_id },
							:title => 'ansehen'
										) if in_welche.include?( :show )
		return html
	end
	
	def zeige_herausgeben_icons( in_reservation )
		html = ''
		if in_reservation.genehmigt?
			if in_reservation.pakete_am_lager?
				html += link_to( image_tag( 'icon_pfeil_l.png', :class => 'icon' ),
									{ :controller => 'ausleihen',
										:action => 'herausgeben',
										:id => in_reservation.id },
									:title => 'herausgeben' )
			else
				html += '<span class="res_ueber">?</span>&nbsp;'
			end
		end
		html += link_to( image_tag( 'icon_pfeil_r.png', :class => 'icon' ),
								{ :controller => 'ausleihen',
									:action => 'zuruecknehmen',
									:id => in_reservation.id },
								:title => 'zurücknehmen'
											) if in_reservation.ausgeliehen?
		return html
	end

	def definiere_array_mit_gegenstaende_in_sammlung
		# aus der session werden Gegenstand IDs gelesen und die
		# entsprechenden Gegenstaende in ein Array gepackt
		@gegenstaende_in_sammlung = Array.new
		unless session[ :gegenstands_auswahl ].nil?
			if session[ :gegenstands_auswahl ].kind_of?( Array )
				unless @gegenstands.nil?
					if @gegenstands.length > 0
						for gegenstand in @gegenstands
							if session[ :gegenstands_auswahl ].include?( gegenstand.id )
								@gegenstaende_in_sammlung << gegenstand
							end
						end
						@gegenstaende_in_sammlung.sort! { |a,b| a.art <=> b.art }
					else
						'gegenstands ist leer'
					end
				else
					'gegenstands ist nil'
				end
			else
				'session ist kein array, sondern' + session[ :gegenstands_auswahl ].type.to_s
			end
		else
			'session ist nil'
		end
		
	end

	def initialisieren_list
	# Funktion, um den View am Anfang mit den richtigen Parametern
	# zu fuellen
		if session[ :gegenstands_mit_sammlung ]
			@mit_sammlung = true
			@hilfeseite = 'h_gegenstand_list_sammlung'
		else
			@mit_sammlung = false
			@hilfeseite = 'h_gegenstand_list'
		end
		
		if session[ :gegenstand_infos ]
			@mit_infos = true
		else
			@mit_infos = false
		end
	end
	
	def gib_leihzeitraum
		session[ :leihzeitraum ] ||= Leihzeitraum.new
	end

	def echo_feld_wenn_definiert( inBezeichner, inInhalt )
		if inInhalt.to_s.length > 0
			html_text = '<p><div class="feldname">'
			html_text += wandle_zu_html( h( inBezeichner ) )
			html_text += '</div>'
			html_text += '<div class="feldinhalt">'
			html_text += wandle_zu_html( h( inInhalt ) )
			html_text += '</div></p>'
			return html_text
		else
			return ''
		end
	end
	
	def echo_tabelle_feld_wenn_definiert( inBezeichner, inInhalt, in_htmllen = true )
		if inInhalt.to_s.length > 0
			html_text = '<tr><td class="feldname">'
			html_text += in_htmllen ? wandle_zu_html( h( inBezeichner ) ) : inBezeichner
			html_text += '</td>'
			html_text += '<td class="feldinhalt">'
			html_text += in_htmllen ? wandle_zu_html( h( inInhalt ) ) : inInhalt
			html_text += '</td></tr>'
			return html_text
		else
			return ''
		end
	end

#----------------------------------------------------------
# Helper für Benutzeridentifikation

	def user_admin?
		return ( session[ :user ] and session[ :user ].admin? )
	end
	def user_herausgeber?
		return ( session[ :user ] and session[ :user ].herausgeber? )
	end
	def user_root?
		return ( session[ :user ] and session[ :user ].root? )
	end
	
	def reservationen_menu?
		return params[ :controller ] =~ /reserv|ausleihen/
	end
	def pakete_menu?
		return params[ :controller ] == 'pakets'
	end
	def benutzer_menu?
		return params[ :controller ] == 'users'
	end
	def verwaltung_menu?
		return ( ( params[ :controller ] == 'admin' and params[ :action ] == 'manage' ) or params[ :controller ] =~ /seher|geraeteparks/ )
	end
	def gegenstaende_menu?
		return params[ :controller ] =~ /egenstan|aufvorgan|omputerdate/
	end
	
#----------------------------------------------------------
# Ausgabe Helper für Reservationen

	def datum_to_html( in_datum )
		if in_datum.year == Time.now.year
			return in_datum.strftime( '%d.%m.' )
		else
			return in_datum.strftime( '%d.%m.%y' )
		end
	end
	
	def zeitraum_to_html( in_reservation = Reservation.new )
		zeitraum_tage = ( ( in_reservation.enddatum - in_reservation.startdatum ) / 60 / 60 / 24 ).round
		if zeitraum_tage < 10
			html_text = zeitraum_tage.to_s + 'T '
		else
			html_text = ( zeitraum_tage / 7 ).round.to_s + 'W '
		end
		html_text += in_reservation.startdatum.strftime( '%d.' )
		html_text += in_reservation.startdatum.strftime( '%m.' ) unless in_reservation.startdatum.month == in_reservation.enddatum.month
		html_text += in_reservation.startdatum.strftime( '%y' ) unless in_reservation.startdatum.year == in_reservation.enddatum.year
		html_text += '-' + in_reservation.enddatum.strftime( '%d.%m.' )
		html_text += in_reservation.enddatum.strftime( '%y' ) unless in_reservation.enddatum.year == Time.now.year
		return html_text
	end
	
	def status_to_html( in_reservation = Reservation.new )
		html_text = in_reservation.status_text
		
		html_text = '<span class="res_neu">A</span>' if in_reservation.neu?
		html_text = '?' if in_reservation.vorlaeufig?
		html_text = 'R' if in_reservation.genehmigt?
		html_text = '<span class="res_sonst">X</span>' if in_reservation.abgelehnt?
		html_text = '<span class="res_aus">V</span>' if in_reservation.ausgeliehen?
		html_text = '<span class="res_zurueck">Z</span>' if in_reservation.zurueck?

		html_text = '<span class="res_ueber">!!</span>' if in_reservation.ueberfaellig?
		return html_text
	end
	
	def htmlle ( in_was, in_text )
		case in_was
			when :ausleihbefugnis, :benutzerstufe
				html_text = '<span class="kleingrau" style="color:'
				case in_text
					when /Mitarbeiter/ then html_text += '#69F'
					when /speziell/ then html_text += '#77D'
					when /Herausgeber/ then html_text += '#949'
					when /gesperrt|neu/ then html_text += '#F00'
					when /Admin|root/ then html_text += '#990'
				end
				html_text += '">' + in_text + '</span>'
		end
		return html_text
	end
	
	def reservationsstatus( in_reservation )
		if in_reservation.zusammenstellen?
		  html = '<span class="res_zusammen">wird zusammengestellt</span>'
		elsif in_reservation.neu?
			html = '<span class="res_neu">neu</span>'
		elsif in_reservation.vorlaeufig?
			html = '<span class="res_sonst">vorläufig</span>'
		elsif in_reservation.genehmigt?
			html = '<span class="res_sonst">genehmigt</span>'
		elsif in_reservation.abgelehnt?
			html = '<span class="res_aus">abgelehnt</span>'
		elsif in_reservation.ausgeliehen?
			if in_reservation.ueberfaellig?
				html = '<span class="res_ueber">überfällig!!</span>'
			else
				html = '<span class="res_aus">ausgeliehen</span>'
			end
		elsif in_reservation.zurueck?
			html = '<span class="res_zurueck">zurück</span>'
		end
		return html
	end

	def reservation_class( in_reservation )
		text = 'hell'
		text = 'res_zusammen' if in_reservation.zusammenstellen?
		text = 'res_neu' if in_reservation.neu?
		text = 'res_genehm' if in_reservation.genehmigt?
		text = 'res_aus' if in_reservation.ausgeliehen?
		text = 'res_ueber' if in_reservation.nicht_zurueckgebracht?
		text = 'res_zurueck' if in_reservation.zurueck?
		return text
	end
	
	def wochentag( in_datum = Time.now )
		case in_datum.wday
			when 0 then 'So'
			when 1 then 'Mo'
			when 2 then 'Di'
			when 3 then 'Mi'
			when 4 then 'Do'
			when 5 then 'Fr'
			when 6 then 'Sa'
		end
	end
	
	def anzahl_pakete( in_reservation )
		return in_reservation.pakets.size if in_reservation.pakets
	end
	
#----------------------------------------------------------
# Ausgabe Helper für Paketlisten

	def art_array_aus_pakete( in_pakete )
		# extrahiere aus einem Feld von Paketen
		# die Liste der verschiedenen Paketarten
		t_art_array = Array.new
		if in_pakete.is_a?( Array )
			for paket in in_pakete
				t_art_array << paket.art unless t_art_array.include?( paket.art )
			end
			t_art_array.sort
		end
		#logger.debug( "I --- application helper | art array aus pakete -- return #{t_art_array.to_yaml}")
		return t_art_array
	end
	
	def pakete_array_mit_art( in_pakete, in_art )
		# extrahiere aus einem Feld von Pakete diejenigen,
		# deren Art mit in_art übereinstimmen
		t_pakete_array = Array.new
		if in_pakete.is_a?( Array )
			for paket in in_pakete
				t_pakete_array << paket if paket.art == in_art
			end
		end
		#logger.debug( "I --- application helper | pakete array mit art -- return #{t_pakete_array.to_yaml}")
		return t_pakete_array
	end

end