/**
 * Clearable Input
 * @version: 1.0 (2011/11/14)
 * @author Sebastian Pape
 * 
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 * 
 * 
 * ***** EXAMPLE ****
 * 
 * <input class="clearable"/>
 * Just add "clearable" to the class names of the input field you want to make clearable
 * dont forget to style the clear icons!!!
 * 
 * ******************
 * 
**/

$(document).ready(function(){
  ClearableInput.setup();
});

var ClearableInput = new ClearableInput();

function ClearableInput() {
  
  this.setup = function() {
    this.setupClearableInputFields();  
  }
  
  this.setupClearableInputFields = function() {
    var clear_icon;
    var _input;
    var hideOnInput = false;
    
    $("input.clearable").each(function(){
      _input = this;
      clear_icon = $("<div class='clear_icon'></div>");
      $(clear_icon).css("display", "inline-block").hide();
      
      // check if clear icon is should be visible
      if($(_input).val() != "" && $(_input).val() != $(_input).data("start_text")) {
        $(clear_icon).css("display", "inline-block").show();
        $(this).siblings(".search.icon").hide();
        hideOnInput = true;
      }
      
      // bind key up on input field
      if(hideOnInput) {
        $(_input).bind("keyup", function() {
          $(clear_icon).css("display", "inline-block").hide();
          $(this).siblings(".search.icon").show();
        });
      }
      
      // add click icon to the dom
      $(_input).after(clear_icon);
      clear_icon = $("input.clearable").siblings(".clear_icon");
      
      // bind click on clear icon
      $(clear_icon).click(function() {
        $(_input).val("").focus();
        $(this).hide();
        $(this).siblings(".search.icon").show();
      });
    });
  }
}