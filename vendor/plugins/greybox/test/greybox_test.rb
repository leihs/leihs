require 'test/unit'
require File.join(File.dirname(__FILE__), '../../../../config/environment.rb')
require File.join(File.dirname(__FILE__), '../lib/greybox')

class GreyboxTest < Test::Unit::TestCase
  include Greybox
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::CaptureHelper
  
  def setup
    # request = ActionController::TestRequest.new({}, {}, nil)
  end
  
  def test_should_generate_valid_greybox_image_link
    output = greybox_link_to_image(nil, '/images/something.jpg', :title => 'Fun images!') do
      "Click me"
    end 
    expected = '<a href="/images/something.jpg" rel="gb_image[]" title="Fun images!">Click me</a>'
    assert_equal expected, output
  end

  def test_should_generate_valid_greybox_image_links
    # <a href="static_files/salt.jpg" rel="gb_imageset[nice_pics]" title="Salt flats in Chile">Salt flats</a>
    # <a href="static_files/night_valley.jpg" rel="gb_imageset[nice_pics]" title="Night valley">Night valley</a>
    # _erbout = ''
    output = greybox_links('Nice pics') do
      greybox_link_to_image(nil, 'static_files/salt.jpg', :title => "Salt flats in Chile") do
        "Salt flats"
      end +
      greybox_link_to_image("Night valley", 'static_files/night_valley.jpg', :title => "Night valley")
    end
    expected = '<a href="static_files/salt.jpg" rel="gb_imageset[nice_pics]" title="Salt flats in Chile">Salt flats</a><a href="static_files/night_valley.jpg" rel="gb_imageset[nice_pics]" title="Night valley">Night valley</a>'
    assert_equal expected, output
  end

  def test_should_generate_valid_greybox_page_link
    # <a href="http://google.com/" title="Google" rel="gb_page_center[500, 500]">Launch Google.com</a>
    expected = '<a href="http://google.com/" rel="gb_page_center[500, 501]" title="Google">Launch Google.com</a>'
    output = greybox_link_to_page("Launch Google.com", 'http://google.com/', :title => 'Google', :width => 500, :height => 501)
    assert_equal expected, output
  end
  
  def test_should_generate_valid_greybox_page_link_when_fullscreen
    # <a href="http://google.com/" title="Google" rel="gb_page_fs[]">Launch Google.com</a>
    expected = '<a href="http://google.com/" rel="gb_page_fs[]" title="Google">Launch Google.com</a>'
    output = greybox_link_to_page(nil, 'http://google.com/', :title => 'Google', :fullscreen => true) do
      "Launch Google.com"
    end
    assert_equal expected, output
  end

  def test_should_generate_valid_greybox_page_links
    expected = '<a href="http://google.com/" rel="gb_pageset[search_sites]" title="Google">Launch Google search</a><a href="http://search.yahoo.com/" rel="gb_pageset[search_sites]">Launch Yahoo search</a>'
    output = greybox_links 'search sites' do
      greybox_link_to_page("Launch Google search", 'http://google.com/', :title => 'Google') +
      greybox_link_to_page(nil, 'http://search.yahoo.com/') do
        "Launch Yahoo search"
      end
    end
    assert_equal expected, output
  end

  def test_should_generate_valid_script_head
    expected = "<script type=\"text/javascript\">
        var GB_ROOT_DIR = \"http://www.somedomain.com/greybox/\";
    </script>
    <script type=\"text/javascript\" src=\"http://www.somedomain.com/greybox/AJS.js\"></script>
    <script type=\"text/javascript\" src=\"http://www.somedomain.com/greybox/AJS_fx.js\"></script>
    <script type=\"text/javascript\" src=\"http://www.somedomain.com/greybox/gb_scripts.js\"></script>
    <link href=\"http://www.somedomain.com/greybox/gb_styles.css\" rel=\"stylesheet\" type=\"text/css\" />"
    output = greybox_head('http://www.somedomain.com/greybox/')
    assert_equal expected, output
    output = greybox_head('http://www.somedomain.com/greybox')
    assert_equal expected, output
  end
  
  def test_should_generate_valid_greybox_page_advance_link_with_default_height_and_width
    # <a href="http://google.com/" onclick="return GB_show('Google', this.href, 501, 500)">Launch Google.com</a>
    expected = '<a href="http://google.com/" onclick="return GB_show(\'Launch Google.com\', this.href, 500, 650)" title="Google">Launch Google.com</a>'
    output = greybox_advance_link_to_page("Launch Google.com", 'http://google.com/', :title => 'Google')
    assert_equal expected, output
  end

  def test_should_generate_valid_greybox_page_advance_link
    # <a href="http://google.com/" onclick="return GB_show('Google', this.href, 501, 500)">Launch Google.com</a>
    expected = '<a href="http://google.com/" onclick="return GB_show(\'Launch Google.com\', this.href, 501, 500)" title="Google">Launch Google.com</a>'
    output = greybox_advance_link_to_page("Launch Google.com", 'http://google.com/', :title => 'Google', :width => 500, :height => 501)
    assert_equal expected, output
  end

  def test_should_generate_valid_greybox_page_advance_link_centered
    # <a href="http://google.com/" onclick="return GB_show('Google', this.href, 501, 500)">Launch Google.com</a>
    expected = '<a href="http://google.com/" onclick="return GB_showCenter(\'Launch Google.com\', this.href, 501, 500)" title="Google">Launch Google.com</a>'
    output = greybox_advance_link_to_page("Launch Google.com", 'http://google.com/', :title => 'Google', :width => 500, :height => 501, :center => true)
    assert_equal expected, output
  end

  def test_should_generate_valid_greybox_page_advance_link_in_full_screen_mode
    # <a href="http://google.com/" onclick="return GB_showFullScreen('Google', this.href)">Launch Google.com</a>
    expected = '<a href="http://google.com/" onclick="return GB_showFullScreen(\'Launch Google.com\', this.href)" title="Google">Launch Google.com</a>'
    output = greybox_advance_link_to_page("Launch Google.com", 'http://google.com/', :title => 'Google', :fullscreen => true)
    assert_equal expected, output
  end
end
