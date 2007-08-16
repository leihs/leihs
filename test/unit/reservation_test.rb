require File.dirname(__FILE__) + '/../test_helper'

class ReservationTest < Test::Unit::TestCase
	
  fixtures :reservations, :users

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @reservation = Reservation.find( 1 )
  end

  # Teste die Erzeugung von Reservationen durch die Fixtures
  def test_create
    assert_kind_of Reservation,  @reservation
		assert_equal 1, @reservation.id
		assert_equal 'hansdam', @reservation.user.login
		assert_equal @hans_dampf.id, @reservation.updater_id
		assert_equal ( 4.days.from_now.at_midnight + 10.hours ).strftime("%Y-%m-%d %H:%M:%S"), @reservation.startdatum_before_type_cast
  end

	# Teste einen Änderungsvorgang einer Reservation
	def test_update
		assert @reservation.save, @reservation.errors.full_messages.join( '; ' )
		@reservation.reload
	end
	
	# Teste, ob eine Reservation korrekt gelöscht wird
	def test_destroy
		@reservation.destroy
		assert_raise( ActiveRecord::RecordNotFound ) { Reservation.find( @reservation.id ) }
	end
	
	# Teste, ob die Validierung der Daten funktioniert
	def test_validate_datum
		yo = reservations( :vorlaeufige_von_hans )
		yo.startdatum = 8.days.from_now
		assert !yo.save
		assert_equal 1, yo.errors.count
		#assert yo.errors.on( :startdatum ).include?( 'Zukunft' )
		
		yo2 = reservations( :vorlaeufige_von_hans )
		yo2.startdatum = Time.now + 2.days
		#assert yo2.save
		#assert_equal 0, yo2.errors.count
		
		yo2.enddatum = yo2.startdatum - 1.day
		assert !yo2.save
		assert_equal 1, yo2.errors.count
		assert_equal 'sollte nach Startdatum liegen', yo2.errors.on( :enddatum )

		yo2.enddatum = @vorlaeufige_von_hans.startdatum + 30.minutes
		#assert yo2.save
		#assert_equal 0, yo2.errors.count
	end
	
end
