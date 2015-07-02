###
  
  Model

###

class window.App.Model extends Spine.Model

  @configure "Model", "id", "product", "version", "type", "properties", "accessories"
  
  @hasOne "availability", "App.Availability", "model_id"
  @hasMany "plainAvailabilities", "App.PlainAvailability", "model_id"
  @hasMany "properties", "App.Property"
  @hasMany "accessories", "App.Accessory"
  @hasMany "items", "App.Item"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  @url: => "/models"

  name: -> [@product, @version].join(" ").trim()

  accessory_names: -> (_.uniq _.map @accessories().all(), (a)->a.name).join ", "
