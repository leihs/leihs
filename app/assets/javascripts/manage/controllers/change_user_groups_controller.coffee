class window.App.ChangeUserGroupsController extends Spine.Controller

  elements:
    "input[name='name']": "input"
    "[data-group-list]": "groupList"

  events:
    "focus input[name='name']": "search"
    "preChange input[name='name']": "search"
    "click [data-remove-group]": "removeGroup"

  constructor: ->
    super
    @input.preChange()

  search: =>
    @searchGroups().done (data) =>
      @setupAutocomplete(App.Group.find datum.id for datum in data)

  searchGroups: =>
    App.Group.ajaxFetch
      data: $.param
        search_term: @input.val()

  setupAutocomplete: (groups) =>
    @input.autocomplete
      source: (request, response) => response groups
      focus: => return false
      select: @select
      minLength: 0
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "manage/views/groups/autocomplete_element", item).data("value", item).appendTo(ul)
    @input.autocomplete("search")

  select: (e, ui) =>
    @groupList.append(App.Render "manage/views/groups/group_entry", ui.item)
    @input.blur()

  removeGroup: (e) ->
    e.preventDefault()
    $(e.currentTarget).closest(".line").remove()
