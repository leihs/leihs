begin; require 'rubygems'; rescue LoadError; end
require 'zlib'
require 'inline'

class String # :nodoc: # ZenTest SKIP

  ##
  # Calculates a CRC using the algorithm in the PNG specification.

  inline do |builder|
    if RUBY_VERSION < "1.8.6" then
      builder.prefix <<-EOM
        #define RSTRING_PTR(s) (RSTRING(s)->ptr)
        #define RSTRING_LEN(s) (RSTRING(s)->len)
      EOM
    end

    builder.c <<-EOM
      unsigned long png_crc() {
        static unsigned long crc[256];
        static char crc_table_computed = 0;
      
        if (! crc_table_computed) {
          unsigned long c;
          int n, k;
        
          for (n = 0; n < 256; n++) {
            c = (unsigned long) n;
            for (k = 0; k < 8; k++) {
              c = (c & 1) ? 0xedb88320L ^ (c >> 1) : c >> 1;
            }
            crc[n] = c;
          }
          crc_table_computed = 1;
        }

        unsigned long c = 0xffffffff;
        unsigned len = RSTRING_LEN(self);
        char * s = StringValuePtr(self);
        unsigned i;

        for (i = 0; i < len; i++) {
          c = crc[(c ^ s[i]) & 0xff] ^ (c >> 8);
        }

        return c ^ 0xffffffff;
      }
    EOM
  end
end

##
# An almost-pure-ruby Portable Network Graphics (PNG) writer.
#
# http://www.libpng.org/pub/png/spec/1.2/
#
# PNG supports:
# + 8 bit truecolor PNGs
#
# PNG does not support:
# + any other color depth
# + extra data chunks
# + filters
#
# = Example
#
#   require 'png'
#
#   canvas = PNG::Canvas.new 200, 200
#   canvas[100, 100] = PNG::Color::Black
#   canvas.line 50, 50, 100, 50, PNG::Color::Blue
#   png = PNG.new canvas
#   png.save 'blah.png'

class PNG

  VERSION = '1.1.0'
  SIGNATURE = [137, 80, 78, 71, 13, 10, 26, 10].pack("C*")

  inline do |builder|
    if RUBY_VERSION < "1.8.6" then
      builder.prefix <<-EOM
        #define RARRAY_PTR(s) (RARRAY(s)->ptr)
        #define RARRAY_LEN(s) (RARRAY(s)->len)
      EOM
    end

    # C equivalent of:
    # @data.map { |row| "\0" + row.map { |p| p.values }.join }.join
    builder.c <<-EOM
      VALUE png_join() {
        int i, j;
        VALUE data = rb_iv_get(self, "@data");
        unsigned int data_len = RARRAY_LEN(data);
        unsigned int row_len = RARRAY_LEN(RARRAY_PTR(data)[0]);
        unsigned long size = data_len * (1 + (row_len * 4));
        char * result = malloc(size);
        unsigned long idx = 0;
        for (i = 0; i < data_len; i++) {
          VALUE row = RARRAY_PTR(data)[i];
          result[idx++] = 0;
          for (j = 0; j < row_len; j++) {
            VALUE color = RARRAY_PTR(row)[j];
            VALUE values = rb_iv_get(color, "@values");
            char * value = StringValuePtr(values);
            result[idx++] = value[0];
            result[idx++] = value[1];
            result[idx++] = value[2];
            result[idx++] = value[3];
          }          
        }
        return rb_str_new(result, size);
      }
    EOM
  end

  ##
  # Creates a PNG chunk of type +type+ that contains +data+.

  def self.chunk(type, data="")
    [data.size, type, data, (type + data).png_crc].pack("Na*a*N")
  end

  def self.load(png)
    png = png.dup
    signature = png.slice! 0, 8
    raise ArgumentError, 'Invalid PNG signature' unless signature == SIGNATURE

    type, data = read_chunk png

    raise ArgumentError, 'Invalid PNG, no IHDR chunk' unless type == 'IHDR'

    canvas = read_IHDR data
    type, data = read_chunk png
    read_IDAT data, canvas
    type, data = read_chunk png
    raise 'oh no! IEND not next? crashing and burning!' unless type == 'IEND'

    new canvas
  end

  def self.check_crc(type, data, crc)
    return true if (type + data).png_crc == crc
    raise ArgumentError, "Invalid CRC encountered in #{type} chunk"
  end

  def self.paeth(a, b, c) # left, above, upper left
    p = a + b - c
    pa = (p - a).abs
    pb = (p - b).abs
    pc = (p - c).abs

    return a if pa <= pb && pa <= pc
    return b if pb <= pc
    c
  end

  def self.read_chunk(png)
    size, type = png.slice!(0, 8).unpack 'Na4'
    data, crc = png.slice!(0, size + 4).unpack "a#{size}N"

    check_crc type, data, crc

    return type, data
  end

  def self.read_IDAT(data, canvas)
    data = Zlib::Inflate.inflate(data).unpack 'C*'
    scanline_length = 4 * canvas.width + 1 # for filter
    row = 0
    until data.empty? do
      row_data = data.slice! 0, scanline_length
      filter = row_data.shift
      case filter
      when 0 then # None
      when 1 then # Sub
        row_data.each_with_index do |byte, index|
          left = index < 4 ? 0 : row_data[index - 4]
          row_data[index] = (byte + left) % 256
          #p [byte, left, row_data[index]]
        end
      when 2 then # Up
        row_data.each_with_index do |byte, index|
          col = index / 4
          upper = row == 0 ? 0 : canvas[col, row - 1].values[index % 4]
          row_data[index] = (upper + byte) % 256
        end
      when 3 then # Average
        row_data.each_with_index do |byte, index|
          col = index / 4
          upper = row == 0 ? 0 : canvas[col, row - 1].values[index % 4]
          left = index < 4 ? 0 : row_data[index - 4]

          row_data[index] = (byte + ((left + upper)/2).floor) % 256
        end
      when 4 then # Paeth
        left = upper = upper_left = nil
        row_data.each_with_index do |byte, index|
          col = index / 4

          left = index < 4 ? 0 : row_data[index - 4]
          if row == 0 then
            upper = upper_left = 0
          else
            upper = canvas[col, row - 1].values[index % 4]
            upper_left = col == 0 ? 0 :
                           canvas[col - 1, row - 1].values[index % 4]
          end

          paeth = paeth left, upper, upper_left
          row_data[index] = (byte + paeth) % 256
          #p [byte, paeth, row_data[index]]
        end
      else
        raise ArgumentError, "Invalid filter algorithm #{filter}"
      end

      col = 0
      row_data.each_slice 4 do |slice|
        canvas[col, row] = PNG::Color.new(*slice)
        col += 1
      end

      row += 1
    end
  end

  def self.read_IHDR(data)
    width, height, *rest = data.unpack 'N2C5'
    raise ArgumentError, 'unsupported PNG file' unless rest == [8, 6, 0, 0, 0]
    return PNG::Canvas.new(height, width)
  end

  ##
  # Creates a new PNG object using +canvas+

  def initialize(canvas)
    @height = canvas.height
    @width = canvas.width
    @bits = 8
    @data = canvas.data
  end

  ##
  # Writes the PNG to +path+.

  def save(path)
    File.open path, 'wb' do |f| f.write to_blob end
  end

  ##
  # Raw PNG data

  def to_blob
    blob = []

    blob << SIGNATURE
    blob << PNG.chunk('IHDR', [@width, @height, @bits, 6, 0, 0, 0 ].pack("N2C5"))
    # 0 == filter type code "none"
    data = self.png_join
    blob << PNG.chunk('IDAT', Zlib::Deflate.deflate(data))
    blob << PNG.chunk('IEND', '')
    blob.join
  end

  ##
  # RGBA colors

  class Color

    attr_reader :values

    def self.from str, name = nil
      str = "%08x" % str if Integer === str
      colors = str.scan(/[\da-f][\da-f]/i).map { |n| n.hex }
      colors << name
      self.new(*colors)
    end

    ##
    # Creates a new color with values +red+, +green+, +blue+, and +alpha+.

    def initialize(red, green, blue, alpha, name = nil)
      @values = "%c%c%c%c" % [red, green, blue, alpha]
      @name = name
    end

    ##
    # Transparent white

    Background = Color.from 0x00000000, "Transparent"
    Black      = Color.from 0x000000FF, "Black"
    Blue       = Color.from 0x0000FFFF, "Blue"
    Brown      = Color.from 0x996633FF, "Brown"
    Bubblegum  = Color.from 0xFF66FFFF, "Bubblegum"
    Cyan       = Color.from 0x00FFFFFF, "Cyan"
    Gray       = Color.from 0x7F7F7FFF, "Gray"
    Green      = Color.from 0x00FF00FF, "Green"
    Magenta    = Color.from 0xFF00FFFF, "Magenta"
    Orange     = Color.from 0xFF7F00FF, "Orange"
    Purple     = Color.from 0x7F007FFF, "Purple"
    Red        = Color.from 0xFF0000FF, "Red"
    White      = Color.from 0xFFFFFFFF, "White"
    Yellow     = Color.from 0xFFFF00FF, "Yellow"

    def ==(other) # :nodoc:
      self.class === other and other.values == values
    end

    ##
    # Red component

    def r; @values[0]; end

    ##
    # Green component

    def g; @values[1]; end

    ##
    # Blue component

    def b; @values[2]; end

    ##
    # Alpha transparency component

    def a; @values[3]; end

    ##
    # Blends +color+ into this color returning a new blended color.

    def blend(color)
      return Color.new((r * (0xFF - color.a) + color.r * color.a) >> 8,
                       (g * (0xFF - color.a) + color.g * color.a) >> 8,
                       (b * (0xFF - color.a) + color.b * color.a) >> 8,
                       (a * (0xFF - color.a) + color.a * color.a) >> 8)
    end

    ##
    # Returns a new color with an alpha value adjusted by +i+.

    def intensity(i)
      return Color.new(r,g,b,(a*i) >> 8)
    end

    def inspect # :nodoc:
      if @name then
        "#<%s %s>" % [self.class, @name]
      else
        "#<%s %02x %02x %02x %02x>" % [self.class, r, g, b, a]
      end
    end

    ##
    # An ASCII representation of this color, almost suitable for making ASCII
    # art!

    def to_ascii
      return '  ' if a == 0x00
      brightness = (((r + g + b) / 3) * a) / 0xFF
      return '00' if brightness >= 0xc0
      return '++' if brightness >= 0x7F
      return ',,' if brightness >= 0x40
      return '..'
    end

    def to_s
      if @name then
        @name
      else
        super
      end
    end
  end

  ##
  # PNG canvas

  class Canvas

    ##
    # Height of the canvas

    attr_reader :height

    ##
    # Width of the canvas

    attr_reader :width

    ##
    # Raw data

    attr_reader :data

    def initialize(width, height, background = Color::Background)
      @width = width
      @height = height
      @data = Array.new(@height) { |x| Array.new(@width, background) }
    end

    ##
    # Retrieves the color of the pixel at (+x+, +y+).

    def [](x, y)
      raise "bad x value #{x} >= #{@width}" if x >= @width
      raise "bad y value #{y} >= #{@height}" if y >= @height
      @data[@height-y-1][x]
    end

    ##
    # Sets the color of the pixel at (+x+, +y+) to +color+.

    def []=(x, y, color)
      raise "bad x value #{x} >= #{@width}" if x >= @width
      raise "bad y value #{y} >= #{@height}"  if y >= @height
      @data[@height-y-1][x] = color
    end

    def inspect # :nodoc:
      '#<%s %dx%d>' % [self.class, @width, @height]
    end

    ##
    # Blends +color+ onto the color at point (+x+, +y+).

    def point(x, y, color)
      self[x,y] = self[x,y].blend(color)
    end

    ##
    # Draws a line using Xiaolin Wu's antialiasing technique.
    #
    # http://en.wikipedia.org/wiki/Xiaolin_Wu's_line_algorithm

    def line(x0, y0, x1, y1, color)
      y0, y1, x0, x1 = y1, y0, x1, x0 if y0 > y1
      dx = x1 - x0
      sx = dx < 0 ? -1 : 1
      dx *= sx
      dy = y1 - y0

      # 'easy' cases
      if dy == 0 then
        Range.new(*[x0,x1].sort).each do |x|
          point(x, y0, color)
        end
        return
      end

      if dx == 0 then
        (y0..y1).each do |y|
          point(x0, y, color)
        end
        return
      end

      if dx == dy then
        x0.step(x1, sx) do |x|
          point(x, y0, color)
          y0 += 1
        end
        return
      end

      # main loop
      point(x0, y0, color)
      e_acc = 0
      if dy > dx then # vertical displacement
        e = (dx << 16) / dy
        (y0...y1-1).each do |i|
          e_acc_temp, e_acc = e_acc, (e_acc + e) & 0xFFFF
          x0 = x0 + sx if (e_acc <= e_acc_temp)
          w = 0xFF-(e_acc >> 8)
          point(x0, y0, color.intensity(w))
          y0 = y0 + 1
          point(x0 + sx, y0, color.intensity(0xFF-w))
        end
        point(x1, y1, color)
        return
      end

      # horizontal displacement
      e = (dy << 16) / dx
      (dx - 1).downto(0) do |i|
        e_acc_temp, e_acc = e_acc, (e_acc + e) & 0xFFFF
        y0 += 1 if (e_acc <= e_acc_temp)
        w = 0xFF-(e_acc >> 8)
        point(x0, y0, color.intensity(w))
        x0 += sx
        point(x0, y0 + 1, color.intensity(0xFF-w))
      end
      point(x1, y1, color)
    end

    ##
    # Returns an ASCII representation of this image

    def to_s
      image = []
      scale = (@width / 39) + 1

      @data.each_with_index do |row, x|
        next if x % scale != 0
        row.each_with_index do |color, y|
          next if y % scale != 0
          image << color.to_ascii
        end
        image << "\n"
      end

      return image.join
    end
  end
end
