# PDF_Gbarcode, an extension for Ruby FPDF
#
# It has bugs! Mail them to ramon.cahenzli@gmail.com 
#
# This is version 0.3
#
# ----- License and Copyright
#
# Copyright 2008 Ramon Cahenzli
# Development sponsored by the Zurich University of the Arts
# Visit our code server at http://code.zhdk.ch
#
# Written for FPDF 1.53 by Olivier Plathey,
# which was ported to Ruby by Brian Ollenberger
# Ruby FPDF is Copyright 2005 Brian Ollenberger
#
# Licensed under the same terms as FPDF: Any use is allowed without
# any restrictions.
# 
#
# ----- Description
#
# Ruby FPDF extension that prints barcodes generated using Gbarcode.
# It takes a Gbarcode object and prints it as lines (actually, rectangles).
#
# The barcode object must be pre-encoded so it can be used! Make sure to
# call barcode_encode on it.
#
# x and y are the X and Y coordinates of the start point of the barcode.
# It will cheerfully print off the page if the barcode is too wide to
# fit.
#
#
# ----- Usage
#
# pdf.Gbarcode(barcode object, x, y, height)
#
# Example:
#
# require 'fpdf'
# require 'fpdf_gbarcode'
# require 'rubygems'
# require 'gbarcode'
# bc = Gbarcode::barcode_create( "0192LALA12" )
# Gbarcode::barcode_encode(bc, Gbarcode::BARCODE_128)
#
# pdf = FPDF.new
# pdf.extend(PDF_Gbarcode)
# pdf.Gbarcode(bc, 20.0, 20.0, 3.0)

require 'rubygems'
require 'gbarcode'

module PDF_Gbarcode
  def Gbarcode(bc, x = 0, y = 0, h = 20.0)
  
    barThicknessFactor = 0.3
  
    originalLineWidth = @LineWidth
    originalDrawColor = @DrawColor
    originalFillColor = @FillColor
    
    # Gbarcode's barcodes start with white, then alternate between black and white
    @whiteColor = 255
    @blackColor = 0
    @BarcodeFillColor = @whiteColor
    
    bc_height = h
    
    # Set starting position for drawing
    self.SetXY(x,y)
    
    # Handling of Code 39 in gbarcode is a bit quirky: The start/stop character
    # (usually represented by "*") is not included in the encoded barcode. This is
    # why we have to re-check the encoding here and add the padding if it's Code 39.
    if bc.encoding == "code 39"
      newbc = Gbarcode::barcode_create("*" + bc.ascii + "*")
      Gbarcode::barcode_encode(newbc, Gbarcode::BARCODE_39 | Gbarcode::BARCODE_NO_CHECKSUM)
      bc = newbc
    end
    
    bc_widths= bc.partial.split(//)
    bc_widths.each do |w|
      w = w.to_f
      # This factor makes the bars a bit narrower. Seems to look more barcode-like
      bar_width = w * barThicknessFactor

      self.SetFillColor(@BarcodeFillColor)
      self.Rect(self.GetX, self.GetY, bar_width, bc_height, "F")
      self.SetX(self.GetX + bar_width)
      flipColor
    end

    @LineWidth = originalLineWidth
    @DrawColor = originalDrawColor
    @FillColor = originalFillColor
  end 
  def flipColor
    if @BarcodeFillColor == @whiteColor
      @BarcodeFillColor = @blackColor
    else
      @BarcodeFillColor = @whiteColor
    end
  end
end
