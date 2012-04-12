/*
 * ListSearch
 *
 * This script sets up functionalities for searching lists
 *
*/

var ListSearch = new ListSearch();

function ListSearch() {
  
  this.setup = function() {
    var search = $(".list .navigation .search input[type=query]");
    
    if($(search).val() != $(search).data("start-text") && $(search).val() != "" && $(search).val() != undefined) $(search).addClass("active");
    
    if($(search).val() == "" || $(search).val() == undefined) $(search).val($(search).data("start_text"));
    
    $(search).focus(function(){
      if(!$(this).data("start_text")) $(this).data("start_text", $(this).val());
      if($(this).val() == $(this).data("start_text")) $(this).val("");
      $('.qtip').qtip('hide').qtip('disable');
    });
    
    $(search).blur(function(){
      if($(this).val() == "") {
        $(this).val($(this).data("start_text"));
        $(this).removeClass("active");
      } else {
        $(this).addClass("active");
      };
      $('.qtip').qtip('enable');
    });
    
    $(search).parents("form").submit(function() {
      $(this).find(".loading").show();
    });
  }
}