###
  
  Option

###

class window.App.Option extends Spine.Model

  @configure "Option", "id", "product", "version", "inventory_pool_id", "inventory_code"

  @extend Spine.Model.Ajax

  @url: "/options"

  name: -> [@product, @version].join(" ")
