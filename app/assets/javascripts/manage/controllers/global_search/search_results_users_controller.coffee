#= require ./search_results_controller
class window.App.SearchResultsUsersController extends App.SearchResultsController

  model: "User"
  templatePath: "manage/views/users/search_result_line"

  fetch: (page, target, callback)=>
    @fetchUsers(page).done =>
      do callback

  fetchUsers: (page)=>
    App.User.ajaxFetch
      data: $.param
        search_term: @searchTerm
    .done (data)=>
      users = (App.User.find datum.id for datum in data)
      App.User.fetchDelegators users
