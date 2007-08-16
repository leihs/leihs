class LogeintraegeController < ApplicationController
	
	scaffold :logeintrag
	layout 'allgemein'
	
	def list
		@tag_text = params[ :id ] || Time.now.strftime( '%y%m%d' )
		@logeintraege = Logeintrag.find( :all,
					:conditions => [ "date_format( created_at, '%y%m%d' ) = ?", @tag_text ],
					:order => 'created_at DESC' )
	end
	
end
