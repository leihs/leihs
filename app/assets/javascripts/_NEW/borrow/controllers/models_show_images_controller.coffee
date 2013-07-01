class window.App.Borrow.ModelsShowImagesController extends Spine.Controller

  elements: 
    "#main-image": "mainImage"

  events:
    "mouseenter [data-image-url]:not(#main-image)": "enterImage"
    "mouseleave [data-image-url]:not(#main-image)": "leaveImage"
    "click [data-image-url]:not(#main-image)": "clickImage"

  constructor: ->
    super
    @lockImage @el.find("[data-image-url]:not(#main-image):first")

  enterImage: (e)=>
    @mouseover = true
    target = $(e.currentTarget)
    @mainImage.attr "src", target.data "image-url"

  leaveImage: (e)=>
    @mouseover = false
    _.delay =>
      if @mouseover == false
        if @currentImage?
          @mainImage.attr "src", @currentImage.data "image-url"
        else
          @mainImage.attr "src", @mainImage.data "image-url"
    , 100

  clickImage: (e)=> @lockImage $(e.currentTarget)

  lockImage: (target)=>
    do @releaseCurrentImage
    target.addClass "focus-thin"
    @currentImage = target

  releaseCurrentImage: =>
    return false unless @currentImage?
    @currentImage.removeClass "focus-thin"