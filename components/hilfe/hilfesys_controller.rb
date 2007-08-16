class Hilfe::HilfesysController < ActionController::Base
	
	uses_component_template_root
	
	def anzeigen
		@hilfeseite = nil
		if session[ :hilfeseite ]
			unless session[ :hilfeseite ].length < 1
				
				case session[ :hilfeseite ]
					when 'geraetepark_infos'
						@geraetepark = Geraetepark.find( session[ :aktiver_geraetepark ] )
						render :action => 'geraetepark_infos'
						
					else
						#logger.debug( "I --- hilfesys con | anzeigen -- hilfeseite:#{session[ :hilfeseite ]}" )
						render :action => ( 'h_' + session[ :hilfeseite ] )
						session[ :hilfeseite ] = nil
				end
			end
		end
	end
	
end
