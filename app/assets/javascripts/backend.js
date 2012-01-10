// This is a manifest file that'll be compiled into including all the files listed below.
// Add new JavaScript/Coffee code in separate files in this directory and they'll automatically
// be included in the compiled file accessible from http://example.com/assets/application.js
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.

/////////// Gem /////////////
//= require jquery.min
//= require jquery-ui.min
//= require jquery_ujs
//= require jquery-tmpl

/////////// App /////////////
//= require i18n/i18n
//= require tips/tips
//= require buttons/buttons
//= require dialog/dialog
//= require list/list
//= require selection-actions/selection-actions
//= require barcode/barcode
//= require clearable-input/clearable-input
//= require daily-navigator/daily-navigator
//= require lines/grouped
//= require lines/max_range
//= require lines/max_date
//= require lines/min_date

/////////// Templates /////////////
//= require_tree ./tmpl

/////////// Lib /////////////
//= require showMore/showMore
//= require historical-search/historical-search
//= require booking-calendar/booking-calendar

/////////// Vendor /////////////
//= require date/date
//= require fullcalendar/fullcalendar
//= require qtip/qtip.min
//= require jqBarGraph/jqBarGraph.1.2.js
//= require pagination/pagination

// type or global formating/accepting of ajax requestes
$.ajaxSetup({
  data: {format: "js"},
  dataType: 'json'
});