#!/usr/local/bin/ruby -w

require 'png'

class PNG
  FULL = 360.0
  HALF = FULL / 2

  def self.angle(x, y)
    return 0 if x == 0 and y == 0
    rad_to_deg = 180.0 / Math::PI
    (Math.atan2(-y, x) * rad_to_deg + 90) % 360
  end

  ##
  # Makes a pie chart you can pass to PNG.new:
  #
  #   png = PNG.new pie_chart(250, 0.30)
  #   png.save "pie.png"
  #   system 'open pie.png'

  def self.pie_chart(diameter, pct_green,
                good_color=PNG::Color::Green, bad_color=PNG::Color::Red)
    diameter += 1 if diameter % 2 == 0
    radius = (diameter / 2.0).to_i
    pct_in_deg = FULL * pct_green
    rad_to_deg = HALF / Math::PI

    canvas = PNG::Canvas.new(diameter, diameter)

    (-radius..radius).each do |x|
      (-radius..radius).each do |y|
        magnitude = Math.sqrt(x*x + y*y)
        if magnitude <= radius then
          angle = PNG.angle(x, y)
          color = ((angle <= pct_in_deg) ? good_color : bad_color)

          rx, ry = x+radius, y+radius

          canvas[ rx, ry ] = color
        end
      end
    end

    canvas
  end
end
