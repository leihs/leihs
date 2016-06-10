# NOTE: this could be a generic 'ReactViewController',
# the constructors just needs to take a React Component as argument

class window.App.HandOverAutocompleteController

  constructor: (@props, @container, @opts) ->

  _render: ->
    @instance = \
      ReactDOM.render(
        React.createElement(HandoverAutocomplete, @props),
        @container
      )
    window.reactBarcodeScannerTarget = @instance

  # like 'setState' inside React, but for integration with other controllers etc
  setProps: (newProps) ->
    _.extend(@props, newProps)
    @_render()

  getInstance: () -> @instance
