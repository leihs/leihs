###
  
  CategoryLink

###

class window.App.CategoryLink extends Spine.Model

  @configure "CategoryLink", "id", "ancestor_id", "descendant_id", "direct", "count"
  
  @extend Spine.Model.Ajax

  @belongsTo "ascendant", "App.Category", "ancestor_id"
  @belongsTo "descendant", "App.Category", "descendant_id"

  @url: => "category_links"