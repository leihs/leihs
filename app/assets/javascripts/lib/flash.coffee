class window.App.Flash

  constructor: (data, zindex)-> 
    flash = $("#flash")
    if zindex? then flash.css("z-index", zindex) else flash.removeAttr("style")
    flash.html App.Render "views/flash", data
    flash.removeClass "hidden"

  @reset: =>
    $("#flash").empty().addClass("hidden")

jQuery ->

  $(document).on "click", "#flash [data-remove]", (e)=> do App.Flash.reset