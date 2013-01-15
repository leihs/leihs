angular.module("ng-rails-csrf", []).config ["$httpProvider", ($httpProvider) ->
  authToken = undefined
  authToken = $("meta[name=\"csrf-token\"]").attr("content")
  $httpProvider.defaults.headers.common["X-CSRF-TOKEN"] = authToken
]