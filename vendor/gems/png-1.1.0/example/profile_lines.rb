require 'png'

class PNGProfileLine

  COLORS = [
    PNG::Color::Red,
    PNG::Color::Orange,
    PNG::Color::Yellow,
    PNG::Color::Green,
    PNG::Color::Blue,
    PNG::Color::Purple,
  ]

  def draw
    line = 0
    canvas = PNG::Canvas.new 100, 100

    0.step 99, 10 do |x|
      canvas.line x, 0, 99 - x, 99, COLORS[line % 6]
      line += 1
    end

    0.step 99, 10 do |y|
      canvas.line 0, y, 99, y, COLORS[line % 6]
      line += 1
    end

    canvas
  end

end

ppl = PNGProfileLine.new

5.times do ppl.draw end
#PNG.new(ppl.draw).save 'x.png'

