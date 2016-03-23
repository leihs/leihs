#= require jquery
#= require jquery-ui
#= require jquery-ujs
#= require jquery.remotipart
#= require bootstrap
#= require accounting.js
#= require jquery-tokeninput
#= require bootstrap-multiselect
#
#= require_self

$(document).ready ->
  $('form').on 'submit', ->
    $(this).find('.btn-success > i.fa.fa-check').removeClass('fa-check').addClass('fa-circle-o-notch spinner')

  $('body').on 'focus mouseover', '[data-toggle="tooltip"]', -> $(this).tooltip('toggle')
