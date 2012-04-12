###

Loading Image Icons

This script provides functionalities for buffering loading images,
so that they are displayed immediatly when neede (dont wait until the image is loaded)
for example: if you want to display a loading indicator for an ajax.
 
###

jQuery ()->
  LoadingImage.setup()

class LoadingImage
  
  @img
  @clones
  
  @setup = ()->
    @img = $.tmpl "tmpl/loading/loading_img"
    @clones = Array()
    @clone(5)
    
  @clone = (x)->
    for time in [1..x]
      @clones.push $(@img).clone()
    
  @get = ()->
    @clone 1
    return @clones.shift()

window.LoadingImage = LoadingImage