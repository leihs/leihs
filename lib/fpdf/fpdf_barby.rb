# PDF_Barby, an extension for Ruby FPDF
#
# It has bugs! Mail them to ramon.cahenzli@gmail.com 
#
# This is version 0.1
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
# Ruby FPDF extension that prints barcodes generated using Barby.
# It takes a barcode object and prints it as lines (actually, rectangles).
#
# x and y are the X and Y coordinates of the start point of the barcode.
# It will cheerfully print off the page if the barcode is too wide to
# fit.
#
#
# ----- Usage
#
# pdf.Barby(barcode object, x, y, height)
#
# Example:
#
# require 'fpdf'
# require 'fpdf_barby'
# require 'rubygems'
# require 'barby'
# bc = Barby::Code128A.new( "0192LALA12" )
#
# pdf = FPDF.new
# pdf.extend(PDF_Barby)
# pdf.AddPage
# pdf.Barby(bc, 20.0, 20.0, 3.0)

require 'rubygems'
require 'barby'

module PDF_Barby
  def Barby(bc, x = 0, y = 0, h = 20.0)
  
    bar_width = 0.3
  
    originalLineWidth = @LineWidth
    originalDrawColor = @DrawColor
    originalFillColor = @FillColor
    originalDrawColor = @DrawColor


    
    # White and black are relative terms. Just make sure to have
    # strong contrast between the two, and that "black" is the darker color
    @whiteColor = 255
    @blackColor = 0
    
    bc_height = h
    
    # Set starting position for drawing
    self.SetXY(x,y)
    
    bc_bars= bc.encoding.split(//)
    
    bc_bars.each do |b|
  
      if b.to_i == 0
        @BarcodeFillColor = @whiteColor
      else
        @BarcodeFillColor = @blackColor
      end

      self.SetFillColor(@BarcodeFillColor)
      self.SetDrawColor(@BarcodeFillColor)
      self.Rect(self.GetX, self.GetY, bar_width, bc_height, "DF")
      self.SetX(self.GetX + bar_width)
    end

    @LineWidth = originalLineWidth
    @DrawColor = originalDrawColor
    @FillColor = originalFillColor
    @DrawColor = originalDrawColor
  end
  
end
