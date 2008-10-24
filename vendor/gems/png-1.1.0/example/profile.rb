require 'png'

class PNGProfile

  def draw
    canvas = PNG::Canvas.new 400, 400
    png = PNG.new canvas
    png.to_blob
  end

end

pp = PNGProfile.new

10.times do pp.draw end

