class window.App.Role extends Spine.Model

  @configure "Role", "id", "name"

  @extend Spine.Model.Ajax

  @url: => "/manage/roles"
