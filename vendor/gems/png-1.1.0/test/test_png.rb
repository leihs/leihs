require 'test/unit'
require 'rubygems'
require 'png'
require 'png/pie'

class TestPng < Test::Unit::TestCase

  def setup
    @canvas = PNG::Canvas.new 5, 10, PNG::Color::White
    @png = PNG.new @canvas

    @IHDR_length = "\000\000\000\r"
    @IHDR_crc = "\2152\317\275"
    @IHDR_crc_value = @IHDR_crc.unpack('N').first
    @IHDR_data = "\000\000\000\n\000\000\000\n\b\006\000\000\000"
    @IHDR_chunk = "#{@IHDR_length}IHDR#{@IHDR_data}#{@IHDR_crc}"

    @blob = <<-EOF.unpack('m*').first
iVBORw0KGgoAAAANSUhEUgAAAAUAAAAKCAYAAAB8OZQwAAAAD0lEQVR4nGP4
jwUwDGVBALuJxzlQugpEAAAAAElFTkSuQmCC
    EOF
  end

  def test_class_check_crc
    assert PNG.check_crc('IHDR', @IHDR_data, @IHDR_crc_value)
  end

  def test_class_check_crc_exception
    begin
      PNG.check_crc('IHDR', @IHDR_data, @IHDR_crc_value + 1)
    rescue ArgumentError => e
      assert_equal "Invalid CRC encountered in IHDR chunk", e.message
    else
      flunk "exception wasn't raised"
    end
  end

  def test_class_chunk
    chunk = PNG.chunk 'IHDR', [10, 10, 8, 6, 0, 0, 0 ].pack('N2C5')
    assert_equal @IHDR_chunk, chunk
  end

  def test_class_chunk_empty
    chunk = PNG.chunk 'IHDR'
    expected = "#{0.chr * 4}IHDR#{["IHDR".png_crc].pack 'N'}"
    assert_equal expected, chunk
  end

  def test_to_blob
    assert_equal @blob, @png.to_blob
  end

  def test_save
    path = "blah.png"
    @png.save(path)
    assert_equal @blob, File.read(path)
  ensure
    assert_equal 1, File.unlink(path)
  end

class TestCanvas < Test::Unit::TestCase

  def setup
    @canvas = PNG::Canvas.new 5, 10, PNG::Color::White
  end

  def test_index
    assert_equal PNG::Color::White, @canvas[1, 2]
    assert_same @canvas[1, 2], @canvas.data[1][2]
  end

  def test_index_tall
    @canvas = PNG::Canvas.new 2, 4, PNG::Color::White
    @canvas[ 0, 0] = PNG::Color::Black
    @canvas[ 0, 3] = PNG::Color::Background
    @canvas[ 1, 0] = PNG::Color::Yellow
    @canvas[ 1, 3] = PNG::Color::Blue

    expected = "  ,,\n0000\n0000\n..++\n"

    assert_equal expected, @canvas.to_s
  end

  def test_index_wide
    @canvas = PNG::Canvas.new 4, 2, PNG::Color::White
    @canvas[ 0, 0] = PNG::Color::Black
    @canvas[ 3, 0] = PNG::Color::Background
    @canvas[ 0, 1] = PNG::Color::Yellow
    @canvas[ 3, 1] = PNG::Color::Blue

    expected = "++0000,,\n..0000  \n"

    assert_equal expected, @canvas.to_s
  end

  def test_index_bad_x
    begin
      @canvas[6, 1]
    rescue => e
      assert_equal "bad x value 6 >= 5", e.message
    else
      flunk "didn't raise"
    end
  end

  def test_index_bad_y
    begin
      @canvas[1, 11]
    rescue => e
      assert_equal "bad y value 11 >= 10", e.message
    else
      flunk "didn't raise"
    end
  end

  def test_index_equals
    @canvas[1, 2] = PNG::Color::Red
    assert_equal PNG::Color::Red, @canvas[1, 2]
    assert_same @canvas[1, 2], @canvas.data[7][1]

    expected = "
0000000000
0000000000
0000000000
0000000000
0000000000
0000000000
0000000000
00,,000000
0000000000
0000000000".strip + "\n"
    actual = @canvas.to_s
    assert_equal expected, actual
  end

  def test_index_equals_bad_x
    begin
      @canvas[6, 1] = PNG::Color::Red
    rescue => e
      assert_equal "bad x value 6 >= 5", e.message
    else
      flunk "didn't raise"
    end
  end

  def test_index_equals_bad_y
    begin
      @canvas[1, 11] = PNG::Color::Red
    rescue => e
      assert_equal "bad y value 11 >= 10", e.message
    else
      flunk "didn't raise"
    end
  end

#   def test_point
#     raise NotImplementedError, 'Need to write test_point'
#   end

  def test_inspect
    assert_equal "#<PNG::Canvas 5x10>", @canvas.inspect
  end

  def test_point
    assert_equal PNG::Color.new(0xfe, 0x00, 0xfe, 0xfe),
                 @canvas.point(0, 0, PNG::Color::Magenta)
    # flunk "this doesn't test ANYTHING"
  end

  def test_line
    @canvas.line 0, 9, 4, 0, PNG::Color::Black

    expected = <<-EOF
..00000000
,,00000000
00,,000000
00..000000
00++++0000
0000..0000
0000++++00
000000..00
000000,,00
00000000..
    EOF

    assert_equal expected, @canvas.to_s
  end

  def test_positive_slope_line
    @canvas.line 0, 0, 4, 9, PNG::Color::Black

    expected = <<-EOF
00000000..
00000000,,
000000,,00
000000..00
0000++++00
0000..0000
00++++0000
00..000000
00,,000000
..00000000
    EOF

    assert_equal expected, @canvas.to_s
  end

  def util_ascii_art(width, height)
    (("0" * width * 2) + "\n") * height
  end

  def test_to_s_normal
    @canvas = PNG::Canvas.new 5, 10, PNG::Color::White
    expected = util_ascii_art(5, 10)
    assert_equal expected, @canvas.to_s
  end

  def test_to_s_wide
    @canvas = PNG::Canvas.new 250, 10, PNG::Color::White
    expected = util_ascii_art(36, 2) # scaled
    assert_equal expected, @canvas.to_s
  end

  def test_to_s_tall
    @canvas = PNG::Canvas.new 10, 250, PNG::Color::White
    expected = util_ascii_art(10, 250)
    assert_equal expected, @canvas.to_s
  end

  def test_to_s_huge
    @canvas = PNG::Canvas.new 250, 250, PNG::Color::White
    expected = util_ascii_art(36, 36) # scaled
    assert_equal expected, @canvas.to_s
  end

#   def test_class_read_chunk
#     type, data = PNG.read_chunk @IHDR_chunk

#     assert_equal 'IHDR', type
#     assert_equal @IHDR_data, data
#   end

#   def test_class_read_IDAT
#     canvas = PNG::Canvas.new 10, 10, PNG::Color::White

#     data = "x\332c\370O$`\030UH_\205\000#\373\216\200"

#     PNG.read_IDAT data, canvas

#     assert_equal @blob, PNG.new(canvas).to_blob
#   end

#   def test_class_read_IHDR
#     canvas = PNG.read_IHDR @IHDR_data
#     assert_equal 10, canvas.width
#     assert_equal 10, canvas.height
#   end
end

class TestPng::TestColor < Test::Unit::TestCase
  def setup
    @color = PNG::Color.new 0x01, 0x02, 0x03, 0x04
  end

  def test_class_from_str
    @color = PNG::Color.from "0x01020304"
    test_r
    test_g
    test_b
    test_a
  end

  def test_class_from_int
    @color = PNG::Color.from 0x01020304
    test_r
    test_g
    test_b
    test_a
  end

  def test_r
    assert_equal 0x01, @color.r
  end

  def test_g
    assert_equal 0x02, @color.g
  end

  def test_b
    assert_equal 0x03, @color.b
  end

  def test_a
    assert_equal 0x04, @color.a
  end

  def test_blend
    c1 = @color
    c2 = PNG::Color.new 0xFF, 0xFE, 0xFD, 0xFC

    assert_equal PNG::Color.new(0xfb, 0xfa, 0xf9, 0xf8), c1.blend(c2)
  end

  def test_intensity
    assert_equal PNG::Color.new(0x01, 0x02, 0x03, 0x3c), @color.intensity(0xf00)
  end

  def test_inspect
    assert_equal "#<PNG::Color 01 02 03 04>", @color.inspect
  end

  def test_inspect_name
    assert_equal "#<PNG::Color Red>", PNG::Color::Red.inspect
  end

  def test_to_ascii
    assert_equal '00', PNG::Color::White.to_ascii, "white"
    assert_equal '++', PNG::Color::Yellow.to_ascii, "yellow"
    assert_equal ',,', PNG::Color::Red.to_ascii, "red"
    assert_equal '..', PNG::Color::Black.to_ascii, "black"
    assert_equal '  ', PNG::Color::Background.to_ascii, "background"
  end

  def test_to_ascii_alpha
    assert_equal '00', PNG::Color.new(255,255,255,255).to_ascii
    assert_equal '00', PNG::Color.new(255,255,255,192).to_ascii
    assert_equal '++', PNG::Color.new(255,255,255,191).to_ascii
    assert_equal '++', PNG::Color.new(255,255,255,127).to_ascii
    assert_equal ',,', PNG::Color.new(255,255,255,126).to_ascii
    assert_equal ',,', PNG::Color.new(255,255,255, 64).to_ascii
    assert_equal '..', PNG::Color.new(255,255,255, 63).to_ascii
    assert_equal '..', PNG::Color.new(255,255,255,  1).to_ascii
    assert_equal '  ', PNG::Color.new(255,255,255,  0).to_ascii
  end

  def test_to_s_name
    assert_equal 'Red', PNG::Color::Red.to_s
  end

  def test_to_s
    obj = PNG::Color.new(255,255,255,  0)
    assert_equal '#<PNG::Color:0xXXXXXX>', obj.to_s.sub(/0x[0-9a-f]+/, '0xXXXXXX')
  end

#   def test_values
#     raise NotImplementedError, 'Need to write test_values'
#   end
end

end

class TestPng::TestPie < Test::Unit::TestCase
  def setup

  end

  def test_pie_chart_odd
    expected =
      ["          ..          ",
       "    ,,,,,,........    ",
       "  ,,,,,,,,..........  ",
       "  ,,,,,,,,..........  ",
       "  ,,,,,,,,..........  ",
       ",,,,,,,,,,............",
       "  ,,,,,,,,,,,,,,,,,,  ",
       "  ,,,,,,,,,,,,,,,,,,  ",
       "  ,,,,,,,,,,,,,,,,,,  ",
       "    ,,,,,,,,,,,,,,    ",
       "          ,,          ",
      nil].join("\n")

    actual = PNG::pie_chart(11, 0.25, PNG::Color::Black, PNG::Color::Green)
    assert_equal expected, actual.to_s
  end

  def test_pie_chart_even
    expected =
      ["          ..          ",
       "    ,,,,,,........    ",
       "  ,,,,,,,,..........  ",
       "  ,,,,,,,,..........  ",
       "  ,,,,,,,,..........  ",
       ",,,,,,,,,,............",
       "  ,,,,,,,,,,,,,,,,,,  ",
       "  ,,,,,,,,,,,,,,,,,,  ",
       "  ,,,,,,,,,,,,,,,,,,  ",
       "    ,,,,,,,,,,,,,,    ",
       "          ,,          ",
      nil].join("\n")

    actual = PNG::pie_chart(10, 0.25, PNG::Color::Black, PNG::Color::Green)
    assert_equal expected, actual.to_s
  end

  def util_angle(expect, x, y)
    actual = PNG.angle(x, y)
    case expect
    when Integer then
      assert_equal(expect, actual,
                   "[#{x}, #{y}] should be == #{expect}, was #{actual}")
    else
      assert_in_delta(expect, actual, 0.5)
    end
  end

  def test_math_is_hard_lets_go_shopping
    util_angle   0,  0,  0
    (25..500).step(25) do |n|
      util_angle   0,  0,  n
      util_angle  90,  n,  0
      util_angle 180,  0, -n
      util_angle 270, -n,  0
    end

    util_angle 359.5, -1, 250
    util_angle   0.0,  0, 250
    util_angle   0.5,  1, 250

    util_angle 89.5, 250,  1
    util_angle 90.0, 250,  0
    util_angle 90.5, 250, -1
  end
end
