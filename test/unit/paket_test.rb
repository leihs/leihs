require File.dirname(__FILE__) + '/../test_helper'

class PaketTest < Test::Unit::TestCase
	
  fixtures :pakets, :reservations, :pakets_reservations

	self.use_transactional_fixtures = false
	self.use_instantiated_fixtures = true

  def setup
    @paket = Paket.find(1)
  end

  # Teste, ob freie in einem Zeitraum gefunden werden
  def test_freie_in_zeitraum
		dat_s = '2005-10-11 10:00:00'.to_time
		assert_kind_of Time, dat_s
		assert_equal 11, dat_s.day
		
		freie_pakete = Paket.find_freie_in_zeitraum( dat_s, dat_s + 3.days, 1, 4 )
    assert_kind_of Array, freie_pakete
		assert_equal 1, freie_pakete.size
	end
	
	# Teste die Funktion komplett_frei mit verschiedenen Varianten
	def test_komplett_frei
		dat = Time.now
		assert_kind_of Time, dat
		
		assert @stativ.komplett_frei?( dat, dat + 6.hours )
		assert @stativ.komplett_frei?( dat, dat + 4.days )
		assert @stativ.komplett_frei?( dat, dat + 15.days )
		dat = dat + 3.days + 4.hours
		assert @jemand_reserviert_stativ_genehmigt.enddatum > dat
		assert @stativ.komplett_frei?( dat, dat + 12.hours )
		assert @stativ.komplett_frei?( dat, dat + 3.days )
	end
	
	def test_komplett_frei_servicetag
		# Teste die Funktion mit Servicetag oder ohne
		# Hole Paket Varilight
		varilight = Paket.find( 861 )
		assert varilight.valid?
		
		# mit Servicetag. Die letzte Reservation geht bis 5.10.
		# Die nächste startet am 10.10.
		assert varilight.komplett_frei?(
			Time.local( 2005, 10, 7 ), Time.local( 2005, 10, 8 ) )
		assert varilight.komplett_frei?(
			Time.local( 2005, 10, 6 ), Time.local( 2005, 10, 8 ) )
		assert !varilight.komplett_frei?(
			Time.local( 2005, 10, 5 ), Time.local( 2005, 10, 8 ) )
			
		assert varilight.komplett_frei?(
			Time.local( 2005, 10, 6 ), Time.local( 2005, 10, 9 ) )
		assert !varilight.komplett_frei?(
			Time.local( 2005, 10, 6 ), Time.local( 2005, 10, 10 ) )
		
		# ohne Servicetag
		assert varilight.komplett_frei?(
			Time.local( 2005, 10, 5 ), Time.local( 2005, 10, 8 ), false )
		assert !varilight.komplett_frei?(
			Time.local( 2005, 10, 4 ), Time.local( 2005, 10, 8 ), false )
			
		assert varilight.komplett_frei?(
			Time.local( 2005, 10, 6 ), Time.local( 2005, 10, 10 ), false )
		assert !varilight.komplett_frei?(
			Time.local( 2005, 10, 6 ), Time.local( 2005, 10, 11 ), false )
	end
	
	# Teste die Funktion ueberlappt_wo mit verschiedenen Varianten
	def test_ueberlappung
		dat = Time.now
		assert_kind_of Time, dat
		
		assert_equal :nichts, @stativ.ueberlappt_wo( dat, dat + 20.hours )
		assert_equal :hinten, @stativ.ueberlappt_wo( dat, dat + 3.days )
		assert_equal :beides, @stativ.ueberlappt_wo( dat + 4.days, dat + 8.days )
		assert_equal :vorne, @stativ.ueberlappt_wo( dat + 10.days, dat + 13.days ) 
		assert_equal :mitte, @stativ.ueberlappt_wo( dat + 1.days, dat + 6.days ) 
	end
	  
end
