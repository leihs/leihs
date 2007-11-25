require 'rubygems'
require 'gbarcode'
require 'RMagick'

include Gbarcode

bc = barcode_create('CTR18282')

barcode_encode(bc, BARCODE_93)

#barcode_print(bc, File.new("test.eps","w") , BARCODE_OUT_EPS)

#png = Image.new(200,100)

#png.display

def with_stdout_captured
   old_stdout = $stdout
   out = StringIO.new
   $stdout = out
   begin
      yield
   ensure
      $stdout = old_stdout
   end
   out.string
end

png = with_stdout_captured do
  barcode_print(bc, $stdout , BARCODE_OUT_EPS)
end

png.format = "PNG"
png.display
