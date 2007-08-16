class Zeitraum
	
	attr_accessor :beginn
	attr_accessor :ende
	
	def initialize( inBeginn = Time.now, inEnde = nil )
		@beginn = inBeginn
		if inEnde.nil?
			@ende = @beginn.tomorrow
		else
			@ende = inEnde
		end
	end

	def dauer()
		return @ende - @beginn
	end
	
	def dauer=( inDauer )
		@ende = @beginn + inDauer * 60
	end
	
	def to_sma()
		return 'von:' + @beginn.to_s + ' bis:' + @ende.to_s
	end
	
end
