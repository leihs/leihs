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

	require 'rubygems'
	require 'gbarcode'
	require 'RMagick'
	require 'base64'

	include Gbarcode
	include Magick

	def get_barcode_eps( string )
		bc = barcode_create( string.to_s )
		barcode_encode(bc, BARCODE_93)

	# print the barcode into a string instead of stdout
		rd, wr = IO.pipe
		barcode_print(bc, wr, BARCODE_NO_ASCII | BARCODE_OUT_EPS)
		wr.close() # must close this to use the read pipe
		bc_eps = rd.readlines().join("\n")
		rd.close()     # it is good practice to also close this pipe

		return bc_eps
	end

	def get_barcode_png( string )
		img = Image.read_inline( Base64.encode64( get_barcode_eps( string) )).first
		img.format = "PNG"
		img.crop!(CenterGravity, img.columns , 30)
		return img
	end


end
