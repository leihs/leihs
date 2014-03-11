class window.App.SearchSetUserController extends Spine.Controller

  events:
    "preChange #user-id": "searchUser"
    "click #remove-user": "removeUser"

  elements:
    "#user-id": "input"
    "#selected-user": "selectedUser"

  constructor: (options)->
    super
    if @localSearch == true
      @setupAutocomplete()
      @input.on "focus", -> $(this).autocomplete("search")
      @input.autocomplete("search") # hack for chrome, because first trigger to autocompletesearch is ignored
    else
      @input.preChange {delay: 200} 

  setupAutocomplete: (users) ->
    autocompleteOptions =
      appendTo: @el
      source: (request, response) => 
        data = _.map users, (u)=>
          u.value = u.id
          u
        response data
      focus: => return false
      select: (e, ui)=> @selectUser(ui.item); return false
    $.extend autocompleteOptions, @customAutocompleteOptions

    @input.autocomplete(autocompleteOptions)
    .data("uiAutocomplete")
    ._renderItem = (ul, item) => 
      $(App.Render "manage/views/users/autocomplete_element", item).data("value", item).appendTo(ul)

  searchUser: ->
    term = @input.val()
    return false if term.length == 0
    data = { search_term: term }
    $.extend data, @additionalSearchParams
    App.User.ajaxFetch
      data: $.param data
    .done (data) =>
      @setupAutocomplete(App.User.find(datum.id) for datum in data)
      @input.autocomplete("search")

  selectUser: (user)->
    @input.hide().autocomplete("disable").attr("value", user.id)
    @selectedUserId = user.id
    @selectedUser.html App.Render "manage/views/contracts/edit/swapped_user", user
    @selectCallback?()

  removeUser: =>
    @input.show().autocomplete("enable").val("").focus()
    @selectedUserId = null
    @selectedUser.html ""
