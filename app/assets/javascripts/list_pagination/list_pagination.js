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
  this.show_loading_dialog = true;
  
  this.setup = function(options) {
    if(options) {
      this.current_page = options.current_page;
      this.per_page = options.per_page;
      this.total_entries = options.total_entries;
      this.next_text = options.next_text;
      this.previous_text = options.previous_text;
      this.show_loading_dialog = options.show_loading_dialog;
    }

    if (this.total_entries <= this.per_page) return false; 
    
    current_page = (ListPagination.current_page == 0) ? 0 : ListPagination.current_page-1;
    
    callback = (options != undefined && options.callback != undefined) ? options.callback : ListPagination.on_click
    $(".pagination_container").pagination(ListPagination.total_entries, {
      items_per_page: ListPagination.per_page,
      callback: callback,
      current_page: current_page,
      num_display_entries: 7,
      num_edge_entries: 2,
      next_text: ListPagination.next_text,
      prev_text: ListPagination.previous_text
    });
    
    return true;
  }
  
  this.on_click = function (new_page_index, pagination_container) {
    var params = window.location.search;
    var page_param = "page="+parseInt(new_page_index+1);
    
    if(this.show_loading_dialog) {
      Dialog.add({
        content: $.tmpl("tmpl/dialog/loading"),
        dialogClass: ".loading"
      });
    }
    
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
