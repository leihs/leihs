class Geraetepark < ActiveRecord::Base
	
	has_and_belongs_to_many :users,
				:order => 'nachname'
	has_many :pakets
	has_many :reservations
	belongs_to :updater, :class_name => 'User', :foreign_key => 'updater_id'
	
	def self.select_liste
		resultat = [ ]
		gruppen = Geraetepark.find( :all, :order => 'name' )
		logger.debug( "I --- gruppen:#{gruppen.to_yaml}" )
		for gruppe in gruppen
			resultat << [ gruppe.name, gruppe.id ]
		end
		return resultat
	end
	
	def self.find_oeffentliche
		return self.find_all_by_oeffentlich( 1 )
	end
end
