//= require jquery.min
//= require jquery-ui.min
//= require jquery_ujs
//= require jquery-tmpl

//= require underscore
//= require_tree ../../../vendor/assets/javascripts/underscore

//= require i18n/i18n
//= require_tree ./i18n/lang

//= require str/str

//= require dialog/dialog
//= require qtip/qtip.min

// type or global formating/accepting of ajax requestes
// TODO GET RID OF THAT (Technical Debt)
$.ajaxSetup({
  data: {format: "js"},
  dataType: 'json'
});

// make Underscore available for jQuery templates
window.Underscore = _
