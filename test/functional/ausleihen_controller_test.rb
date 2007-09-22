require File.dirname(__FILE__) + '/../test_helper'
require 'ausleihen_controller'

# Re-raise errors caught by the controller.
class AusleihenController; def rescue_action(e) raise e end; end

class AusleihenControllerTest < Test::Unit::TestCase
	
	fixtures :reservations, :pakets_reservations, :pakets,
				:gegenstands, :users, :geraeteparks
	
	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = AusleihenController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
	end
	def teardown
	end
	
	def test_zeig
	  get :zeig, :id => 1
	  assert_response :success
	  assert_template 'zeig'
	  assert @response.has_template_object?( 'reservation' )
	end
	
#----------------------------------------------------------
# Schritte einer normalen Herausgabe
	
	def test_herausgeben_ohne_user
		get :herausgeben, :id => 1
		assert_kein_zugang
	end
	
	def test_herausgeben_student
		@request.session[ :user ] = users( :normaler_student )
		get :herausgeben, :id => 1
		assert_kein_zugang
	end
	
	def test_herausgeben
		@request.session[ :user ] = users( :normaler_herausgeber )
		get :herausgeben, :id => 4
		
		assert_response :success
		assert_template 'herausgeben'
		assert @response.has_template_object?( 'reservation' )
		assert assigns( :reservation ).valid?
		#assert @response.has_template_object?( 'user' )
		assert assigns( :user ).valid?
	end
	
	def test_ident_eintragen
		@request.session[ :user ] = users( :normaler_herausgeber )
		@die_reservation = reservations( :student_ohne_id_res_ein_ding )
		assert_valid @die_reservation
		@res_user = @die_reservation.user
		assert_valid @res_user
		assert ( @res_user.ausweis.nil? or @res_user.ausweis.length < 1 )
		
		neue_ident = 'Personalausweis 18827Z65R'
		post :ident_eintragen, :id => @die_reservation.id, :user => { :ausweis => neue_ident }
		
		assert_redirected_to :action => 'herausgeben'
		assert_valid User.find( @res_user.id )
		assert_valid @die_reservation
		assert_equal 'Identifikation des/r Reservierenden eingetragen', flash[ :notice ]
		@geaenderter_user = User.find( @res_user.id )
		assert_equal neue_ident, @geaenderter_user.ausweis
		assert_not_nil @geaenderter_user.password
		assert @geaenderter_user.password.length >= 9
		assert_equal @res_user.password, @geaenderter_user.password
	end
	
	def test_ausleihe_pruefen_ohne_user
		get :ausleihe_pruefen, :id => 1
		assert_kein_zugang
	end
	
	def test_ausleihe_pruefen_student
		@request.session[ :user ] = users( :normaler_student )
		get :ausleihe_pruefen, :id => 1
		assert_kein_zugang
	end
	
	def test_ausleihe_pruefen
		@request.session[ :user ] = users( :normaler_herausgeber )
		@die_reservation = reservations( :student_ohne_id_res_ein_ding )
		assert_valid @die_reservation
		@res_user = @die_reservation.user
		assert_valid @res_user
		assert ( @res_user.ausweis.nil? or @res_user.ausweis.length < 1 )

		get :ausleihe_pruefen, :id => 4

		assert_redirected_to :action => 'herausgeben'
		assert( @response.has_flash_object?( :alarm ) )
	end		
	
#----------------------------------------------------------
# Schritte einer direkten Herausgabe
	
	def test_direkt_heraus_ohne_user
		get :direkt_heraus
		assert_kein_zugang
	end
	
	def test_direkt_heraus_student
		@request.session[ :user ] = users( :normaler_student )
		get :direkt_heraus
		assert_kein_zugang
	end
	
	def test_direkt_heraus
		@request.session[ :user ] = users( :normaler_herausgeber )
		get :direkt_heraus
		assert_response :success
		assert_template 'direkt_heraus'
		
		assert_tag :tag => 'form', :attributes => { :action => "/ausleihen/direkt_pruefen/wahl", :method => 'post' }
		assert_tag :tag => 'form', :attributes => { :action => "/ausleihen/direkt_pruefen/wenig", :method => 'post' }
		assert_tag :tag => 'form', :attributes => { :action => "/ausleihen/direkt_pruefen/alles", :method => 'post' }
		
		assert_tag :tag => 'input', :attributes => { :type => 'submit' }, :ancestor => { :tag => 'form', :attributes => { :method => 'post' } }

		assert_tag :tag => 'input', :attributes => { :type => 'hidden' }
		assert_tag :tag => 'option', :attributes => { :value => '0' }, :ancestor => { :tag => 'select' }
		assert_tag :tag => 'select', :attributes => { :name => "user[benutzerstufe]" }
		assert_tag :tag => 'option', :attributes => { :value => '1' }, :ancestor => { :tag => 'select' }
	end
		
	def test_direkt_pruefen_minimal
		@request.session[ :user ] = users( :normaler_herausgeber )
		@request.session[ :aktiver_geraetepark ] = 4
		startdatum = Time.now
		post :direkt_pruefen, { :id => 'wenig',
					:user => {
								:nachname => 'Hansen',
								:abteilung => 'SBD',
								:benutzerstufe => 1 },
					:reservation => {
								:startdatum => startdatum,
								:enddatum => startdatum + 2.days } }
		
		assert_response :redirect
		assert_redirected_to :action => 'pakete_auswaehlen'
		
		assert_equal true, session[ :reservieren_sammlung ]
		assert_not_nil session[ :reservieren_paketauswahl ]
		assert session[ :reservieren_paketauswahl ].is_a?( Array )
		assert_equal 0, session[ :reservieren_paketauswahl ].size
		
		assert_not_nil session[ :reservation_id ]
	end
	
	def test_pakete_auswaehlen
		@request.session[ :user ] = users( :normaler_herausgeber )
		@request.session[ :aktiver_geraetepark ] = 4
		@request.session[ :reservation_id ] = mach_minimal_reservation_fuer_direkt_heraus.id
		@request.session[ :reservieren_sammlung ] = true
		@request.session[ :reservieren_paketauswahl ] = Array.new
		get :pakete_auswaehlen
		
		assert_response :success
		#assert_tag :tag => 'a', :attributes => { :href => /\/ausleihen\/paket_dazu\/67/ }
		#assert_tag :tag => 'form', :attributes => { :action => "/ausleihen/reservation_abschicken", :method => 'post' }
		#assert_tag :tag => 'input', :attributes => { :type => 'submit', :value => 'reservieren' }, :ancestor => { :tag => 'form', :attributes => { :method => 'post' } }
	end

#----------------------------------------------------------
# Schritte des Rücknahmevorgangs
	
	def test_zuruecknehmen_ohne_user
		get :zuruecknehmen, :id => 5
		assert_kein_zugang
	end
	
	def test_zuruecknehmen
		@request.session[ :user ] = users( :normaler_herausgeber )
		get :zuruecknehmen, :id => 5
	end
	
	def test_ruecknahme_pruefen_ohne_user
		post :ruecknahme_pruefen, :id => 5
		assert_kein_zugang
	end
	
	def test_ruecknahme_pruefen
		testres = Reservation.find( 5 )
		assert testres.startdatum = 5.days.ago.at_midnight
		assert testres.enddatum > testres.startdatum
		assert testres.valid?, "#{testres.to_yaml}"
		 
		@request.session[ :user ] = users( :normaler_herausgeber )
		post :ruecknahme_pruefen, {
					:id => 5,
					:reservation => {
								:bewertung => 1	},
					:zubehoer => { :zurueck => 1 },
					:paket => { '5' => {
								:status => 1,
								:zurueck => 1 } } }
								
		assert_response :success
		assert_template 'ruecknahme_pruefen'
		assert assigns( :reservation ).is_a?( Reservation )
		assert assigns( :reservation ).valid?
		#assert flash[ :notice ].include?( 'wurde zur' )
	end
		
	def test_zuruecknehmen_wenn_zu_spaet_und_folgende_reservation
		# Ein Benutzer hat eine Reservation
		# ein anderer Benutzer hat eine Reservation folgend
		# Der erste Benutzer bringt das Paket zu spät zurueck
		# das andere Paket konnte nicht herausgegeben werden
		# Kann korrekt zurueckgegeben werden?
		
	end
	
	def test_herausgabe_wenn_vorige_reservation_noch_nicht_zurueck
		# Ein Benutzer hat eine Reservation
		# ein anderer Benutzer hat eine Reservation folgend
		# Der erste Benutzer bringt das Paket zu spät zurueck
		# Kann das Paket nicht herausgegeben werden?
		
	end
		
end
