module Hilfe::HilfesysHelper
	
#----------------------------------------------------------
# Ausgabe Helper für Hilfe-System

	def hilfe_einblender( in_id = '1', in_titel = '', in_anfangs_offen = false )
		html = ''
		idzu = in_id + '_zu'
		idauf = in_id + '_auf'
		html += '<div id="' + idzu + '" style="display:' + ( in_anfangs_offen ? 'none' : 'block' ) + ';"><h3 class="hilfe_einblender">'
		html += link_to_function( image_tag( 'klapp_zu.png' ), "Element.toggle('#{idzu}', '#{idauf}')" )
		html += '&nbsp;' + link_to_function( in_titel, "Element.toggle('#{idzu}', '#{idauf}')" ) + '</h3></div>'
		html += '<div id="' + idauf + '" style="display:' + ( in_anfangs_offen ? 'block' : 'none' ) + ';"><h3 class="hilfe_einblender">'
		html += link_to_function( image_tag( 'klapp_auf.png' ), "Element.toggle('#{idzu}', '#{idauf}')" )
		html += '&nbsp;' + link_to_function( in_titel, "Element.toggle('#{idzu}', '#{idauf}')" ) + '</h3>'
		return html
	end
	
end
