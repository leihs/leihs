= PNG

* http://seattlerb.rubyforge.org/

== DESCRIPTION

PNG is an almost-pure-ruby PNG library. It lets you write a PNG
without any C libraries.

== FEATURES

* Very simple interface.
* Outputs simple PNG files with ease.
* Basic PNG reader as well (someday it might do compositing and the like!).
* Almost pure ruby, does require a compiler.

== SYNOPSYS

    require 'png'
    
    canvas = PNG::Canvas.new 200, 200
    
    # Set a point to a color
    canvas[100, 100] = PNG::Color::Black
    
    # draw an anti-aliased line
    canvas.line 50, 50, 100, 50, PNG::Color::Blue
    
    png = PNG.new canvas
    png.save 'blah.png'

== REQUIREMENTS

+ C compiler
+ RubyInline
+ Hoe

== INSTALL

+ sudo gem install -y png

== LICENSE

(The MIT License)

Copyright (c) 2006-2007 Ryan Davis, Eric Hodel, Zen Spider Software

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
