angular.module("directives", []).directive "whenInview", ->
  (scope, elm, attr) ->
    raw = elm[0]
    $(window).bind "scroll", ->
      scope.$apply attr.whenInview  if isScrolledIntoView(elm)


isScrolledIntoView = (elem) ->
  docViewTop = $(window).scrollTop()
  docViewBottom = docViewTop + $(window).height()
  elemTop = $(elem).offset().top
  elemBottom = elemTop + $(elem).height()
  (elemBottom <= docViewBottom) and (elemTop >= docViewTop)