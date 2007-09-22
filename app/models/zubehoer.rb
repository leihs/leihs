class Zubehoer < ActiveRecord::Base
  
  belongs_to :reservation
  
	# Fake Methode für das Rücknahme Formular
	def zurueck
		return false
	end

end
