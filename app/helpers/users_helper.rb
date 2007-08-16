module UsersHelper
	
	def user_name_nachname_zuerst( in_user )
		text = h( in_user.nachname + ( in_user.vorname.blank? ? '' : ( ', ' + in_user.vorname ) ) )
		return text
	end
	
	def ping
		return 'ping'
	end
	
end
