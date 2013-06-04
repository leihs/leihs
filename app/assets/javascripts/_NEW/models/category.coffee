###
  
  Category

###

class window.App.Category extends Spine.Model

  @configure "Category", "id", "name"
  
  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  @hasMany "descendants", "App.CategoryLink", "ancestor_id"
  @hasMany "ascendants", "App.CategoryLink", "descendant_id"

  @url: => "categories"

  children: => _.map @descendants().findAllByAttribute("direct", true), (l)->l.descendant()

  parents: => _.map @ascendants().findAllByAttribute("direct", true), (l)->l.ascendant()