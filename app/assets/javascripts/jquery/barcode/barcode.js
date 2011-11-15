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
          console.log("ENTER: " + Barcode.scannerInput);
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
}