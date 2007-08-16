require_dependency "login_system"

class GegenstandsController < ApplicationController
	
	include LoginSystem
	before_filter :admin_required
	
	layout 'allgemein'
	
#----------------------------------------------------------
# Alles was fuer das auflisten gebraucht wird
	
	def index
		list
		render :action => 'list'
	end
	def list
		session[ :hilfeseite ] = 'gegenstand_list'
		@sort = session[ :gegenstand_sort ] ||= 'modellbezeichnung'
		@ord = session[ :gegenstand_ord ] ||= 'ASC'
		geraetepark = Geraetepark.find( session[ :aktiver_geraetepark ] )
		
		@filter = session[ :gegenstand_filter ] ||= Filter.new(
					:selectliste => Gegenstand.felder_selectliste )
		filterbedingung = "( length( herausgabe_abteilung ) < 1 or herausgabe_abteilung = '#{geraetepark.name.to_s}')"
		filterbedingung += " and paket_id is null" if session[ :gegenstands_mit_sammlung ]
		if @filter.bedingung
			filterbedingung += " and "
			filterbedingung += @filter.bedingung
		end
		
		#session[ :gegenstand_seite ] = params[ :page ]
		@gegenstands_pages, @gegenstands = paginate( 'gegenstand',
					:conditions => filterbedingung.length > 0 ? filterbedingung : nil,
					:order_by => ( @sort + ' ' + @ord ),
					:per_page => 25 )
		@gegenstand_count_ohne_paket = ( filterbedingung.length > 0 ? Gegenstand.count( :conditions => filterbedingung ) : 0 )
		@gegenstand_count = Gegenstand.count_fuer_berechtigung( session[ :aktiver_geraetepark ] )
		@gegenstaende_in_sammlung = Gegenstand.find( session[ :gegenstands_auswahl ] ) if session[ :gegenstands_mit_sammlung ]
	end
	
#----------------------------------------------------------
# Filter & Sortierung setzen oder aendern

	def setze_filter
		filter_init = params[ :filter ] || { }
		filter_init[ :selectliste ] = Gegenstand.felder_selectliste
		session[ :gegenstand_filter ] = Filter.new( filter_init )
		redirect_to :action => 'list'
	end
	def loesche_filter
		session[ :gegenstand_filter ].text = '' # kein Suchstring
		redirect_to :action => 'list'
	end
	def setze_sortierung
		if params[ :id ] == session[ :gegenstand_sort ]
			if session[ :gegenstand_ord ] == 'ASC'
				session[ :gegenstand_ord ] = 'DESC'
			else
				session[ :gegenstand_ord ] = 'ASC'
			end
		else
			session[ :gegenstand_sort ] = params[ :id ]
			session[ :gegenstand_ord ] = 'ASC'
		end
		redirect_to :action => 'list'
	end
	
#----------------------------------------------------------
# Steuerung der Anzeigeform

	def infos_einblenden
		session[ :gegenstand_infos ] = true
		redirect_to :action => 'list', :page => session[ :gegenstand_seite ]
	end
	def infos_ausblenden
		session[ :gegenstand_infos ] = false
		redirect_to :action => 'list', :page => session[ :gegenstand_seite ]
	end
	
#----------------------------------------------------------
# CRUD Operationen
	
	def new
		@gegenstand = Gegenstand.new
	end
	def create
		@gegenstand = Gegenstand.new( params[ :gegenstand ] )
		@gegenstand.updater = session[ :user ]
		if @gegenstand.save
			@gegenstand.reload
			id = @gegenstand.id
			flash[ :notice ] = "Gegenstand wurde mit der InventarNr. #{id} neu angelegt."
			redirect_to :action => 'list'
		else
			flash[ :notice ] = 'Gegenstand konnte nicht angelegt werden.'
			render_action 'new'
		end
	end
	def show
		@gegenstand = Gegenstand.find( params[ :id ] )
	end
	def edit
		session[ :hilfeseite ] = 'gegenstand_felder'
		@gegenstand = Gegenstand.find( params[ :id ] )
	end
	def update
	  @gegenstand = Gegenstand.find( params[ :id ] )
		@gegenstand.attributes = params[ :gegenstand ]
		@gegenstand.updater = session[ :user ]
		
	  if @gegenstand.save
	    flash[ :notice ] = 'Gegenstand wurde geaendert.'
	    redirect_to :action => 'list', :page => session[ :gegenstand_seite ]
	  else
	    render_action 'edit'
	  end
	end
	def destroy
		@gegenstand = Gegenstand.find( params[ :id ] )
		fehlermeldung = @gegenstand.destroy_moeglich?
		if fehlermeldung == true
			@gegenstand.destroy
		else
			flash[ :notice ] = fehlermeldung
		end
		redirect_to :action => 'list', :page => session[ :gegenstand_seite ]
	end

#----------------------------------------------------------
# Sammlung Operationen

	def sammlung_neu
		session[ :hilfeseite ] = 'paket_schnueren'
		session[ :gegenstands_mit_sammlung ] = true
		session[ :gegenstands_auswahl ] = Array.new
		redirect_to :action => 'list', :page => session[ :gegenstand_seite ]
	end
	def sammlung_loeschen
		session[ :gegenstands_mit_sammlung ] = nil
		session[ :gegenstands_auswahl ] = nil
		redirect_to :action => 'list', :page => session[ :gegenstand_seite ]
	end
	def sammlung_binden
		redirect_to :controller => 'pakets', :action => 'paket_binden'
	end
	def sammlung_dazu
		unless session[ :gegenstands_auswahl ].nil?
			unless session[ :gegenstands_auswahl ].include?( params[ :id ].to_i )
				session[ :gegenstands_auswahl ] << params[ :id ].to_i
			end
		end
		redirect_to :action => 'list', :page => session[ :gegenstand_seite ]
 	end
	def sammlung_weg
		if session[ :gegenstands_auswahl ].kind_of?( Array )
			session[ :gegenstands_auswahl ].delete( params[ :id ].to_i )
		end
		redirect_to :action => 'list', :page => session[ :gegenstand_seite ]
	end

#----------------------------------------------------------
# Attribute Operationen

	def create_attribut
		@gegenstand = Gegenstand.find( params[ :id ] )
		@gegenstand.erzeuge_attribut( params[ :attribut ][ :schluessel ], params[ :attribut ][ :wert ] )
		redirect_to :action => 'edit_attribut', :id => params[ :id ]
	end
	def edit_attribut
		@gegenstand = Gegenstand.find( params[ :id ] )
		@attributs = Attribut.find( :all, :conditions => [ 'ding_nr = ?', @gegenstand.attribut_id ] )
	end
	def update_attribut
		tAttribut = params[ :attribut ]
		@attribut = Attribut.find( tAttribut[ :id ] )
		if @attribut.update_attributes( params[ :attribut ] )
		  flash[ :notice ] = 'Attribut wurde geaendert.'
		  redirect_to :action => 'edit_attribut', :id => params[ :id ]
		else
		  render_action 'edit_attribut'
		end		
	end
	def destroy_attribut
		Attribut.find( params[ :subid ] ).destroy
		redirect_to :action => 'edit_attribut', :id => params[ :id ]
	end
	
end