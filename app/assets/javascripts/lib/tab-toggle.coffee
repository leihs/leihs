$(document).on "click", "[data-tab-toggle]", ->
  tab = $(this)
  $(".active[data-tab-toggle]").removeClass "active"
  tab.addClass "active"
  $(".active[data-tab-target]").removeClass "active"
  tabTarget = $("[data-tab-target=#{tab.data("tab-toggle")}]")
  tabTarget.addClass "active"
  tabTarget.trigger "tab-changed", tab.data("tab-toggle")

  uri = URI(window.location.href).removeQuery("tab").addQuery("tab", tab.data("tab-toggle"))
  window.history.replaceState uri._parts, document.title, uri.toString()