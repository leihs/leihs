###
  Model property
###

class window.App.Property extends Spine.Model

  @configure "Property", "id", "key", "value", "model_id"

  @extend Spine.Model.Ajax

  @url: => "/properties"
