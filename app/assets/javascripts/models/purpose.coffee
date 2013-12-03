###
  
  Purpose

###

class window.App.Purpose extends Spine.Model

  @configure "Purpose", "id", "description"

  @extend Spine.Model.Ajax

  validate: ->
    if not @description? or @description.length == 0
      _jed "no purpose specified"
