#= require ./search_results_controller
class window.App.SearchResultsLicensesController extends App.SearchResultsItemsController

  model: "License"
  templatePath: "manage/views/licenses/line"
  type: "license"
