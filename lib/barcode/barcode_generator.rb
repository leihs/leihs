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
class BarcodeGenerator
	require 'rubygems'
	require 'gbarcode'
	require 'RMagick'
	require 'base64'

	include Gbarcode

	attr_writer :barcode_ascii
	attr_reader :barcode_ascii, :columns

	def initialize( barcode_ascii = nil )
		unless barcode_ascii.nil?
			@barcode_ascii = barcode_ascii
		end

		@columns = 0
	end
	
	def ascii
		return @barcode_ascii
	end

	# Returns an EPS version of the barcode
	def eps
		bc = Gbarcode::barcode_create( @barcode_ascii.to_s )
		Gbarcode::barcode_encode(bc, Gbarcode::BARCODE_128)
	# print the barcode into a variable instead of stdout
		rd, wr = IO.pipe
		Gbarcode::barcode_print(bc, wr, Gbarcode::BARCODE_NO_ASCII | Gbarcode::BARCODE_OUT_EPS)
		wr.close() # must close this to use the read pipe
		bc_eps = rd.readlines().join("\n")
		rd.close()     # it is good practice to also close this pipe

		return bc_eps
	end

	# Saves EPS version to file
	def eps_file( filename )
		bc = Gbarcode::barcode_create( @barcode_ascii.to_s )
		Gbarcode::barcode_encode(bc, Gbarcode::BARCODE_128)
		# print the barcode into a file instead of stdout
		f = File.new("tmp/barcodes/" + filename, "w")
		Gbarcode::barcode_print(bc, f, Gbarcode::BARCODE_NO_ASCII | Gbarcode::BARCODE_OUT_EPS)
		f.close()
	end

	# Returns a PNG version of the barcode, first generating
	# an EPS one internally
	def png
		img = Magick::Image.read_inline( Base64.encode64( self.eps() )).first
		img.density = "200"
		img.format = "PNG"
		img.crop!(Magick::CenterGravity, img.columns , 60)
		return img
	end

	# Saves PNG version to file
	def png_file( filename )
		img = self.png()
		f = File.new("tmp/barcodes/" + filename, "w")
		return img.write(f)
		f.close()
	end

end
