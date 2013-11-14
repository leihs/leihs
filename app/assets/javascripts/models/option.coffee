###
  
  Option

###

class window.App.Option extends Spine.Model

  @configure "Option", "id", "name", "inventory_pool_id", "inventory_code"

  @extend Spine.Model.Ajax

  @url: "/options"