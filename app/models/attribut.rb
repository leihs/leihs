class Attribut < ActiveRecord::Base
	
	def self.finde_max_attribut_id
		resultats = Attribut.find_by_sql( 'SELECT max( ding_nr ) AS max FROM attributs' )
		#logger.warn( ">>-- Attribut_id:#{resultats.first.type}" )
		if resultats.first.max.nil?
			return 1
		else
			return resultats.first.max.to_i + 1
		end
	end 

end
