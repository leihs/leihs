class Logeintrag < ActiveRecord::Base
	
	belongs_to :user
	
	def self.neuer_eintrag( in_user = User.new, in_aktion = 'unbekannt', in_kommentar = nil )
		neueintrag = new( { :created_at => Time.now, :user => in_user, :aktion => in_aktion, :kommentar => in_kommentar } )
		neueintrag.save
	end
	
	def self.letzte_tage_liste( in_anzahl_tage = 10 )
		letzte_tage = self.find_by_sql( "select date_format( created_at, '%Y-%m-%d' ) as tag from logeintraege group by tag order by created_at desc limit #{in_anzahl_tage}" )
		tage_liste = []
		for tage in letzte_tage
			tage_liste << ( tage.tag.to_date )
		end
		return tage_liste
	end
	
end
