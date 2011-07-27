/*
 * Models List Datepicker
 *
 * This script provides functionalities for setting up the jqueryui datepicker
 *
 * @name Models List Sort
 * @author Sebastian Pape <email@sebastianpape.com>
*/

$(document).ready(function(){
    // setup jquery ui datepicker
	$('#topfilter .availability .date').datepicker({
	    firstDay: 1,
        isRTL: false,
        showMonthAfterYear: false,
        yearSuffix: '',
        showOtherMonths: true,
        selectOtherMonths: true,
        showButtonPanel: true
	});
});