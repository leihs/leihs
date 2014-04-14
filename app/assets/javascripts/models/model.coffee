###
  
  Model

###

class window.App.Model extends Spine.Model

  @configure "Model", "id", "product", "version"
  
  @hasOne "availability", "App.Availability", "model_id"
  @hasMany "plainAvailabilities", "App.PlainAvailability", "model_id"
  @hasMany "properties", "App.Property"
  @hasMany "items", "App.Item"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  @url: => "/models"

  name: -> [@product, @version].join(" ")
