###
  
  ModelLink

  connects models with templates

###

class window.App.ModelLink extends Spine.Model

  @configure "ModelLink", "id", "template_id", "model_id", "quantity"

  @hasOne "template", "App.Template", "template_id"

  @extend Spine.Model.Ajax