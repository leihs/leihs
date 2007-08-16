module PaketsHelper
	
	def mehr_als_ein_gegenstand_im_paket?( in_paket )
		return ( in_paket.gegenstands and in_paket.gegenstands.size > 1 )
	end
	
	def hinweis_im_paket?( in_paket )
		return ( in_paket.hinweise and in_paket.hinweise.length > 1 )
	end
	
	def ausleihhinweis_im_paket_und_herausgeber?( in_paket )
		return ( user_herausgeber? and in_paket.hinweise_ausleih and in_paket.hinweise_ausleih.length > 1 )
	end
		
end
