@Pages =
  reset: ->
    @current = 1
    @loading = false
    @all_pages_loaded = false
    @load_next() # in case the first page is not filling the window
  load_next: ->
    if @loading == false and not @all_pages_loaded and ($(window).scrollTop() + $(window).height() > $(".pages").height())
      @loading = true
      $.ajax
        url: document.location.href
        data: {format: 'js', page: @current + 1}
        dataType: "html"
        beforeSend: =>
          @loading = true
          $(".pages + .pages-progress").show()
        success: (html) =>
          if html.trim().length
            @current += 1
            $(html).hide().appendTo(".pages").fadeIn(1000) #$(".pages").append html
          else
            $("#all_pages_loaded").show()
            @all_pages_loaded = true
        complete: =>
          @loading = false
          $(".pages + .pages-progress").hide()
          if ($(window).scrollTop() + $(window).height() > $(".pages").height())
            @load_next()
