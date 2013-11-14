class window.App.ManageUsersViaAutocompleteController extends Spine.Controller

  elements:
    "input[data-search-users]": "input"
    "[data-users-list]": "usersList"

  events:
    "delayedChange input[data-search-users]": "search"
    "click [data-remove-user]": "removeHandler"

  constructor: ->
    super
    @input.delayedChange()

  search: =>
    return false unless @input.val().length
    @fetchUsers().done (data) =>
      @setupAutocomplete(App.User.find datum.id for datum in data)

  fetchUsers: =>
    App.User.ajaxFetch
      data: $.param
        search_term: @input.val()
        per_page: 5

  setupAutocomplete: (users) =>
    @input.autocomplete
      source: (request, response) => response users
      focus: => return false
      select: @select
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "manage/views/groups/users/autocomplete_element", item).data("value", item).appendTo(ul)
    @input.autocomplete("search")

  select: (e, ui) =>
    userElement = @usersList.find("input[value='#{ui.item.id}']").closest(".line")
    if userElement.length
      @usersList.prepend userElement
    else
      @usersList.prepend(App.Render "manage/views/groups/users/user_inline_entry", App.User.find(ui.item.id))
