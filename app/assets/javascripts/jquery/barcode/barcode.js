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
    this.setupBarcodeFields();
    this.setupRecognition();
  }
  
  this.setupRecognition = function() {
    $(window).keypress(function(e){
      e = e || window.event;
      var charCode = (typeof e.which == "number") ? e.which : e.keyCode;
      var _char = String.fromCharCode(charCode)
      if(charCode == 13) {
        if(Barcode.scannerInput != ""){
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
  
  this.setupBarcodeFields = function() {
    $("input.barcode").data("start_text", $("input.barcode").val());
    
    $("input.barcode").focus(function(){
      if($(this).val() == $(this).data("start_text")) {
        $(this).val("");
      }
    });
    
    $("input.barcode").blur(function(){
      if($(this).val() == "") {
        $(this).val($(this).data("start_text"));
      }
    });
  }
  
  this.scannerExecution = function() {
    if($("input:focus, textarea:focus").length) return false;
    // the hierarchical order of input fields which should be executed on global scanner input
    if($("#add_item").length > 0) {
      $("#add_item input.barcode").val("").val(Barcode.scannerInput);
      $("#add_item form").submit();
    } else if($("#search").length > 0) {
      $("#search input").val("").val(Barcode.scannerInput);
      $("#search form").submit();
    }
  }
}