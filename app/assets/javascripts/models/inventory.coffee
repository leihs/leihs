###
  
  Inventory

###

class window.App.Inventory extends Spine.Model

  @configure "Inventory", "id"

  @extend Spine.Model.Ajax

  @include App.Modules.Rooted

  constructor: (data)->
    @rooted data, "option"
    @rooted data, "model"
    @rooted data, "item"
    super

  