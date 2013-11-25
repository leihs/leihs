class window.App.ModelsShowPropertiesController extends Spine.Controller

  elements:
    ".property": "properties"

  events:
    "click #properties-toggle": "toggle"

  constructor: ->
    super
    @open = false
    do @setupShowMore

  setupShowMore: =>
    if @properties.length > 5
      container = $ App.Render "borrow/views/models/show/collapsed_properties"
      @collapsedProperties = container.find "#collapsed-properties"
      @showAllText = container.find "#show-all-properties-text"
      @showLessText = container.find "#show-less-properties-text"
      @toggleEl = container.find "#properties-toggle"
      container.find(".collapsed-inner").html @properties.slice(5, @properties.length)
      @el.append container

  toggle: =>
    if @open
      @open = false
      do @hide
    else
      @open = true
      do @show

  show: =>
    @collapsedProperties.removeClass "collapsed"
    @showAllText.addClass "hidden"
    @showLessText.removeClass "hidden"
    @collapsedProperties.addClass "separated-bottom"

  hide: =>
    @collapsedProperties.addClass "collapsed"
    @showAllText.removeClass "hidden"
    @showLessText.addClass "hidden"
    @collapsedProperties.removeClass "separated-bottom"