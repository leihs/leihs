###
  
  Category

###

class window.App.Category extends Spine.Model

  @configure "Category", "id", "name", "used?"
  
  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  @hasMany "descendants", "App.CategoryLink", "ancestor_id"
  @hasMany "ascendants", "App.CategoryLink", "descendant_id"
  @hasMany "models", "App.ModelLink", "model_id"

  @url: => "/categories"

  is_used: => this['used?'] # hack around coffeescript's existantial operator

  children: => 
    # filter out undefined records, they are coming from the inconsistent database: in some cases model group links reference not existing records!!!
    _.filter _.map(@descendants().findAllByAttribute("direct", true), (l) -> l.descendant()), (c) -> c?

  parents: => 
    # filter out undefined records, they are coming from the inconsistent database: in some cases model group links reference not existing records!!!
    _filter _.map(@ascendants().findAllByAttribute("direct", true), (l) -> l.ascendant()), (c) -> c?

  @roots: =>
    _.filter App.Category.all(), (c)->
      not _.any c.ascendants().all(), (a)-> a.ancestor_id?
