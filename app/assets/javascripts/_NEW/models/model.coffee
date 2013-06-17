###
  
  Model

###

class window.App.Model extends Spine.Model

  @configure "Model", "id", "name"
  
  @hasMany "availabilities", "App.Availability", "model_id"
  @hasMany "properties", "App.Property"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  @url: => "/models"
