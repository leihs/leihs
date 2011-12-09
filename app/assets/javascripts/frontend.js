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

/////////// Lib /////////////
//= require jquery/dialog/dialog

/////////// Vendor /////////////
//= require jquery/textarea-autoresize/autoresize.min
//= require jquery/highlight/highlight.min
//= require date/date
//= require jquery/qtip/qtip.min

// type or global formating/accepting of ajax requestes
$.ajaxSetup({
  data: {format: "js"},
  dataType: 'json'
});