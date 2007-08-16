class Seher
	
	public
	def self.test
		return 'Hier bin ich'
	end
	
# -----------------------------------------------------------------------
# Klassen Methoden fuer script/runner Zugriff

	def self.pruefe_benachrichtigungen( in_user = User.find( 1 ) )
		ueberfaellige = Reservation.find_ueberfaellige
		anz_nicht_zurueckgebracht = 0
		anz_nicht_abgeholt = 0

		for reservation in ueberfaellige
			if reservation.nicht_zurueckgebracht?
				email = LeihsMailer.deliver_mahnung_ueberfaellig( reservation )
				anz_nicht_zurueckgebracht += 1
			else
				email = LeihsMailer.deliver_mahnung_reservation( reservation )
				anz_nicht_abgeholt += 1
			end
		end

		Logeintrag.neuer_eintrag( in_user, 'prueft Benachrichtigungen', "#{anz_nicht_zurueckgebracht} Reservationen nicht zurückgebracht,\n #{anz_nicht_abgeholt} Reservationen nicht abgeholt" )
		
		return ueberfaellige
	end

end
