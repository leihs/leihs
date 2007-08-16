module AusleihenHelper
	
	def benutzer_select_array
		auswahl = [ [ '', '0' ] ]
		auswahl |= User.benutzerliste_mit_benutzerstufe_und_berechtigung(
					1, session[ :aktiver_geraetepark ] )
		return auswahl
	end
	
end
