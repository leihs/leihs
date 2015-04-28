#!/usr/bin/ruby


# The EPS output needs Inkscape installed

require 'rubygems'
require 'barby'
require 'barby/outputter/png_outputter'
require 'barby/outputter/cairo_outputter'

class BarcodeMaker

	def initialize(string)
			@string = string
      @height = 25
			@bc = Barby::Code128B.new(@string.to_s)
	end

	def make_eps
		puts "Making EPS for #{@string}"
		make_svg
   	infile = "svg/barcode_#{@string}.svg"
   	outfile = "eps/barcode_#{@string}.eps"
   	#command = %x[inkscape -z -T -E #\{outfile\} #\{infile\}]
   	system "inkscape -z -T -E #{outfile} #{infile}"
	end

	def make_svg
		unless File.exists?("svg/barcode_#{@string}.svg")
			puts "Making SVG for #{@string}"
			f = File.open("svg/barcode_#{@string}.svg", 'w') 
		  f.write @bc.to_svg(height: @height, margin: 5)
			f.close
		else
			puts 'SVG already there'
		end
	end

end



(25000...26000).each do |i|
	puts "Making barcode #{i.to_s}"
	foo = BarcodeMaker.new("AVZ#{i.to_s}")
	foo.make_eps rescue 'EPS failed' 
	puts 'the world has ended'
end

