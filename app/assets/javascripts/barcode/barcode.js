/*
 * Barcode
 *
 * This script provides functionalities for barcode fields 
 * and implements recognizing inputs coming from a barcode scanner
 *
*/

$(document).ready(function(){
  Barcode.setup();
});

var Barcode = new Barcode();

function Barcode() {
  
  this.scannerMaxDelay = 50;
  this.scannerDelayTimer;
  this.scannerInput = "";
  
  this.setup = function() {
    this.setupRecognition();
  }
  
  this.setupRecognition = function() {
    $(window).keypress(function(e){
      e = e || window.event;
      var charCode = (typeof e.which == "number") ? e.which : e.keyCode;
      var _char = String.fromCharCode(charCode)
      if(charCode == 13) {
        if(Barcode.scannerInput != ""){
          e.preventDefault();
          Barcode.scannerExecution();
          Barcode.scannerInput = "";
        }
      } else {
        Barcode.scannerInput += _char;
        window.clearTimeout(Barcode.scannerDelayTimer);
        Barcode.scannerDelayTimer = window.setTimeout(function(){
          Barcode.scannerInput = "";
        }, Barcode.scannerMaxDelay);
      }
    });
  }
  
  this.scannerExecution = function() {
    // if input field is not focused user hotspots for insert the barcode data
    if($("input:focus, textarea:focus").length){
      var target = $("input:focus, textarea:focus");
      $(target).focus().val("").val(Barcode.scannerInput);
      $(target).closest("form").submit();
    } else {
      // the hierarchical order of input fields which should be executed on global scanner input
      if($("#add_item").length > 0) {
        $("#add_item input.barcode").focus().val("").val(Barcode.scannerInput);
        $("#add_item form").submit();
      } else if($("#search").length > 0) {
        $("#search input").focus().val("").val(Barcode.scannerInput);
        $("#search form").submit();
      }
    }
  }
}