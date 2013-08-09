###
  
  TemplateLine

  a line of a template during the pre order state

###

class window.App.TemplateLine extends Spine.Model

  @configure "TemplateLine", "model_link_id", "template_id", "model_id", "quantity", "start_date", "end_date", "inventory_pool_id", "unborrowable", "available"

  @belongsTo "template", "App.Template", "template_id"

  @belongsTo "model", "App.Model", "model_id"