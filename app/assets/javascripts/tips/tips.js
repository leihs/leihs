/*
 * Tips
 *
 * This script setups the qTips2 globaly
 *
 * @dependencies qTip2
*/

$(document).ready(function(){
  Tips.setup();
});

var Tips = new Tips();

function Tips() {
  
  this.firstShowTimeOut;
  
  this.setup = function() {
    $.fn.qtip.defaults.position.my = 'bottom center';
    $.fn.qtip.defaults.position.at = 'top center';
    $.fn.qtip.defaults.position.viewport = $(window);
    $.fn.qtip.defaults.show.delay = 200;
    $.fn.qtip.defaults.show.solo = true;
    $.fn.qtip.defaults.hide.fixed = true;
    $.fn.qtip.defaults.hide.delay = 200;
    $.fn.qtip.defaults.style.tip.width = 12;
    $.fn.qtip.defaults.style.tip.height = 8;
    $.fn.qtip.defaults.style.classes = "list_tip";
    $.fn.qtip.zindex = 1000;
    $.fn.qtip.defaults.show.effect = function(offset) {$(this).fadeIn();}
    
    $(".hastip").live("mouseenter", Tips.setupTip);
  }
  
  this.setupTip = function(event) {
    var _this = event.currentTarget;
    $(_this).removeClass("hastip");
    $(_this).find(".tip").after("<div class='tiptarget'></div");
    $(_this).find(".tip").next(".tiptarget").position({
      my: "center center",
      at: "center center",
      of: $(_this).find(".tip").closest("li")
    });
    $(_this).qtip({
      content: {
        text: $(_this).find(".tip")
      },
      position: {
        target: $(_this).find(".tiptarget")
      }
    });
    $(_this).qtip('render');
    
    Tips.firstShowTimeOut = window.setTimeout(function(){
      $(_this).qtip('show');
    }, 350);
    
    $(_this).bind("mouseleave", Tips.clearTimeOut);
  }
  
  this.clearTimeOut = function(event) {
    var _this = event.currentTarget;
    $(_this).unbind("mouseleave", Tips.clearTimeOut);
    window.clearTimeout(Tips.firstShowTimeOut);
  }
}