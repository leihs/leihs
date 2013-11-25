###
  
  Template

  a set of models and a quantity for each model

###

class window.App.Template extends Spine.Model

  @configure "Template", "id", "label"

  @hasMany "model_links", "App.ModelLink", "template_id"

  @extend Spine.Model.Ajax