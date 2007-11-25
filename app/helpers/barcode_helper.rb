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
module BarcodeHelper

  def barcode_search( barcode )

    # It's a contract ID!
    if barcode =~ /^CTR\d+/
      id = barcode.scan(/^CTR(\d+)/)[0][0]
      result = Reservation.find_by_id(id)
    end

  return result 
  end
		
end
