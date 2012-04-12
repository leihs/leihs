/*
 * ListPagination
 *
 * This script sets up functionalities for lists pagination
 *
*/

var ListPagination = new ListPagination();

function ListPagination() {
  
  this.per_page;
  this.current_page;
  this.total_entries;
  this.next_text = "Next";
  this.previous_text = "Previous";
  
  this.setup = function() {
    current_page = (ListPagination.current_page == 0) ? 0 : ListPagination.current_page-1;
    
    $(".pagination_container").pagination(ListPagination.total_entries, {
      items_per_page: ListPagination.per_page,
      callback: ListPagination.on_click,
      current_page: current_page,
      num_display_entries: 7,
      num_edge_entries: 2,
      next_text: ListPagination.next_text,
      prev_text: ListPagination.previous_text
    });
    
    $(".pagination_container a").click(function(e){
      Dialog.add({
        content: $.tmpl("tmpl/dialog/loading"),
        dialogClass: ".loading"
      });
    });
  }
  
  this.on_click = function (new_page_index, pagination_container) {
    var params = window.location.search;
    var page_param = "page="+parseInt(new_page_index+1);
    
    if(params.match(/page\=\d+/)) {
      params = params.replace(/page\=\d+/, page_param);
    } else {
      if (params.match(/^\?/)) {
        params = params+"&"+page_param;
      } else {
        params = "?"+page_param;      
      }
    }
    
    window.location = window.location.pathname + params;
    return false;
  }
}