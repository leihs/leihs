# PDF_Rotate, an extension for Ruby FPDF
#
# It has bugs! Mail them to ramon.cahenzli@gmail.com 
#
# Version history:
#
# 0.1: Initial release
# 0.2: Fixed bug that would display blank pages with Adobe Acrobat Reader,
#      but not with other readers.
#
# ----- License and Copyright
#
# Original PHP version is copyright Olivier Plathey
#
# Ported to Ruby by Ramon Cahenzli
#
# Development sponsored by the Zurich University of the Arts
# Visit our code server at http://code.zhdk.ch
#
# Licensed under the same terms as FPDF: Any use is allowed without
# any restrictions.
# 
#
# ----- Description
#
# This Ruby FPDF extension allows you to specify a rotation for all 
# elements printed after it is called. Rotations won't carry over to
# following pages.
#
#
# ----- Usage
#
# pdf.Rotate(float degrees, int x, int y)
#
# Example:
#
# require 'fpdf'
# require 'fpdf_rotate'
#
# pdf = FPDF.new
# pdf.extend(PDF_Rotate)
# pdf.Rotate(53.0)


module PDF_Rotate
  
  def Rotate(angle, x=-1, y=-1)
  
    @angle ||= 0
 
    if x == -1
      x = @x
    end
    
    if y == -1
      y = @y
    end
    
    if @angle != 0
      out('Q')
    end

    @angle = angle
    
    if angle != 0
        angle *= Math::PI/180.0
        c = Math::cos(angle)
        s = Math::sin(angle)
        cx = x*@k
        cy = (@h - y)*@k
        out(sprintf('q %.5f %.5f %.5f %.5f %.2f %.2f cm 1 0 0 1 %.2f %.2f cm',c,s,-s,c,cx,cy,-cx,-cy))
    end
  end
   
  def endpage
    if @angle != 0
      @angle = 0
      out('Q')
    end
    super
  end

end
