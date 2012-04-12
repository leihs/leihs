/*
 * List
 *
 * This script sets up functionalities for lists
 *
*/

var List = new List();

function List() {
  
  this.update_reminder = function(element) {
    $(element).find(".reminder .grey").fadeOut(300, function(){
      $(this).siblings(".text").fadeIn(300);
    });
    $(element).find(".reminder .date").fadeOut(300, function(){
      var _text = "Today " + new Date().getHours() + ":" + new Date().getMinutes();
      $(this).html(_text).fadeIn(300);
    });
  }
  
  this.remove = function(line) {
    var list = $(line).closest(".list")
    $(line).remove();
    // subtract badge
    var badge = $(list).prev(".inlinetabs").find(".tab:first .badge");
    var badge_amount = parseInt($(badge).html());
    $(badge).html(badge_amount-1);
    // subtract showmore toggle
    if($(list).find(".toggle").length > 0) {
      var showmore = $(list).find(".toggle");
      var showmore_html =  $(showmore).html();
      var showmore_val = showmore_html.replace(/<\/*.*?>/g, "");
      var showmore_val_num = parseInt(showmore_val.match(/\d*/g));
      var new_showmore_val = showmore_val.replace(showmore_val_num, showmore_val_num-1);
      var new_showmore_html = showmore_html.replace(showmore_val, new_showmore_val);
      $(showmore).html(new_showmore_html);
      // get new line from hidden container
      for (var i = 0; i < 1; i++) {
        var line = $(list).find(".hidden .line:first");
        $(list).find(".hidden").before(line);
      }
      // no more hidden lines to fetch
      if($(list).find(".hidden .line").length == 0){
        $(list).find(".toggle").remove();
        return 0;
      };
    }
  }
}