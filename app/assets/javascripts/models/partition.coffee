###
  
  Partition

###

class window.App.Partition extends Spine.Model

  @configure "Partition", "model_id", "inventory_pool_id", "group_id", "quantity"

  @extend Spine.Model.Ajax

  @belongsTo "group", "App.Group", "group_id"

  constructor: ->
    super
    do @setId

  setId: ->
    if @model_id? and @inventory_pool_id?
      @id = "#{@model_id}#{@inventory_pool_id}#{@group_id}"