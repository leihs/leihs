require 'rubygems'
require 'gbarcode'
require 'RMagick'
require 'base64'

include Gbarcode
include Magick

bc = barcode_create('CTR18282')

barcode_encode(bc, BARCODE_93)

# print the barcode into a string instead of stdout
rd, wr = IO.pipe
barcode_print(bc, wr, BARCODE_NO_ASCII | BARCODE_OUT_EPS)
wr.close() # must close this to use the read pipe
bc_eps = rd.readlines().join("\n")
rd.close()     # it is good practice to also close this pipe

# Note: we can use this EPS directly in our PDFs because the Ruby
# FPDF port supports loading EPS images. But for other uses (onscreen etc.)
# we need to convert it to something browser-displayable.

img = Image.read_inline( Base64.encode64(bc_eps)).first
img.format = "PNG"
img.crop!(CenterGravity, img.columns , 30)
img.display
