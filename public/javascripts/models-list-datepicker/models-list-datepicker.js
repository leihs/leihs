/*
 * Models List Datepicker
 *
 * This script provides functionalities for setting up the jqueryui datepicker
 *
 * @name Models List Sort
 * @author Sebastian Pape <email@sebastianpape.com>
*/

$(document).ready(function(){
	$('#topfilter .availability .date').datepicker();
	
	$('#topfilter .availability .date').bind("click", function() {
        // modify position of prev and next inside the dom
        var _prev = $(".ui-datepicker-header").find(".ui-datepicker-prev").get();
        $(".ui-datepicker-header").find(".ui-datepicker-prev").remove();
        var _next = $(".ui-datepicker-header").find(".ui-datepicker-next").get();
        $(".ui-datepicker-header").find(".ui-datepicker-next").remove(); 
        
        $(_prev).appendTo(".ui-datepicker-title");
        $(_next).appendTo(".ui-datepicker-title");
	});
	
	
});