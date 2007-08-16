class Filter
	
	attr_accessor :feld
	attr_accessor :text
	
	def initialize( inArgs = [ ] )
		@feld = inArgs[ :feld ] || ''
		@text = inArgs[ :text ] || ''
		setze_felder_selectliste( inArgs[ :selectliste ] )
	end
	
	def setze_felder_selectliste( in_liste = nil )
		@selectliste = in_liste || [ ]
	end
	
	def felder_selectliste
		return @selectliste
	end
	
	def felder
		liste = Array.new
		for eintrag in @selectliste
			liste |= [ eintrag.last ] if eintrag.last and eintrag.last.length > 0
		end
		return liste
	end
	
	def bedingung
		if self.text.length > 0
			vergleich = " LIKE '%#{self.text}%'"
			if self.feld == ''
				bedingung = ( felder.join( vergleich + ' OR ' ) ) + vergleich
			else
				bedingung = feld.to_s + vergleich
			end
		else
			bedingung = nil
		end
		return bedingung
	end
end
