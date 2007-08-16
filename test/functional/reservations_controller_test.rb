require File.dirname(__FILE__) + '/../test_helper'
require 'reservations_controller'

# Re-raise errors caught by the controller.
class ReservationsController; def rescue_action(e) raise e end; end

class ReservationsControllerTest < Test::Unit::TestCase
	
  fixtures :reservations, :pakets_reservations, :pakets, :users

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @controller = ReservationsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
		@request.session[ :user ] = users( :magnus )
  end

  def test_meine
		@request.session[ :user ] = nil
		get :meine
		
    assert_kein_zugang
	end
	def test_meine_von_student
		@request.session[ :user ] = users( :student_sfv )
		get :meine
		
		assert_response :success
  end

  def test_index
    get :index

    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'
    assert_not_nil assigns(:reservations)
  end

	def test_show
		get :show, :id => 1
		
    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:reservation)
    assert assigns(:reservation).valid?
	end
	
  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:reservation)
    assert assigns(:reservation).valid?
  end

  def test_update_ohne_res_daten
    post :update, :id => 1
    assert_response :success
    assert_template 'show'
  end
  def test_update
		neu_start = ( 3.days.from_now.at_midnight + 10.hours )
		neu_end = 9.days.from_now
		post :update, :id => 1,
					:reservation => {
								'status' => 1,
								'startdatum(1i)' => neu_start.year.to_s,
								'startdatum(2i)' => neu_start.month.to_s,
								'startdatum(3i)' => neu_start.day.to_s,
								'enddatum(1i)' => neu_end.year.to_s,
								'enddatum(2i)' => neu_end.month.to_s,
								'enddatum(3i)' => neu_end.day.to_s,
								'pakets' => { '1' => '1' } }
    assert_response :redirect
    assert_redirected_to :controller => 'admin', :action => 'status'
  end

	def test_edit_nicht_erlaubter_benutzer
		# Ein Nutzer ist in einer Reservation eingetragen, für die er
		# eigentlich keine Berechtigung hätte. Nun wird die Reservation
		# editiert, der Benutzer muss verknüpft bleiben
		die_res = Reservation.find( reservations( :genehmigte_reservation_eines_nicht_erlaubten_benutzers_lolo ).id )
		assert die_res.valid?
		assert !die_res.user.blank?, "kein Benutzer verknüpft"
		assert die_res.user.valid?, "nicht valider Benutzer verknüpft"
		assert ( die_res.pakets.size > 0 ), "keine Pakete verknüpft"
		assert ( !die_res.user.hat_berechtigung?( die_res.pakets.first.geraetepark.id ) ), "User hat Berechtigung für dieses Paket"
		
		get :edit, :id => die_res.id
		
		assert_response :success
		if find_tag( :tag => 'select',
					:attributes => { :id => 'reservation_user_id' } )
			assert_tag( :tag => 'option',
						:attributes => { :selected => 'selected' },
						:child => { :content => die_res.user.name_nachname_zuerst } )
		end
	end
	
	def test_update_nicht_erlaubter_benutzer
		# Ein Nutzer ist in einer Reservation eingetragen, für die er
		# eigentlich keine Berechtigung hätte. Nun wird die Reservation
		# editiert, der Benutzer muss verknüpft bleiben
		die_res = Reservation.find( reservations( :genehmigte_reservation_eines_nicht_erlaubten_benutzers_lolo ).id )
		assert die_res.valid?
		assert !die_res.user.blank?, "kein Benutzer verknüpft"
		assert die_res.user.valid?, "nicht valider Benutzer verknüpft"
		assert ( die_res.pakets.size > 0 ), "keine Pakete verknüpft"
		assert ( !die_res.user.hat_berechtigung?( die_res.pakets.first.geraetepark.id ) ), "User hat Berechtigung für dieses Paket"
		
		neu_start = 2.days.from_now.at_midnight
		neu_end = 3.days.from_now.at_midnight
		post :update, :id => die_res.id,
					:reservation => {
								'status' => 1,
								'startdatum(1i)' => neu_start.year.to_s,
								'startdatum(2i)' => neu_start.month.to_s,
								'startdatum(3i)' => neu_start.day.to_s,
								'enddatum(1i)' => neu_end.year.to_s,
								'enddatum(2i)' => neu_end.month.to_s,
								'enddatum(3i)' => neu_end.day.to_s,
								'pakets' => { '1' => '1' } }
    assert_response :redirect
    assert_redirected_to :controller => 'admin', :action => 'status'
	end
	
  def test_destroy
    assert_not_nil Reservation.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Reservation.find(1)
    }
  end

end
