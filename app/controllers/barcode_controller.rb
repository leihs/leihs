#    This file is part of leihs.
#
#    leihs is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 3 of the License, or
#    (at your option) any later version.
#
#    leihs is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    leihs is (C) Zurich University of the Arts
#    
#    This file was written by:
#    Ramon Cahenzli 

class BarcodeController < ApplicationController

	def search
		searchstring = params[:searchstring]
	
		if searchstring.nil? or searchstring.empty?
			@bcnotice = "Kein Suchbegriff angegeben."
		else
			result = barcode_search( searchstring.to_s )
			if result.nil?
				@bcnotice = "Nichts Passendes gefunden."
			elsif result.class.to_s == "Reservation"
				@bcredirect = { :controller => 'reservations', :action => 'show', :id => result.id }
			elsif result.class.to_s == "User"
				@bcredirect = { :controller => 'users', :action => 'show', :id => result.id }
			else
				@bcnotice = "Resultat nicht eindeutig."
			end
		end
	end

	def barcode_search( barcode )
    # It's a contract ID!
    if barcode =~ /^CTR\d+/
      id = barcode.scan(/^CTR(\d+)/)[0][0]
      result = Reservation.find_by_id(id)
		# Might be a user
		elsif barcode =~ /^E?\d{7,8}$/
			id = barcode.scan(/^(E?\d{7,8})$/)[0][0]
			result = User.find_by_ausweis(id)
    end
	
		#logger.info("result of barcode search was #{result.to_s} of type #{result.class}")

  	return result
  end

end
