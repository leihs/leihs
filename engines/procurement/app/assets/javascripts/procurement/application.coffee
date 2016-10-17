#= require jquery
#= require jquery-ui
#= require jquery-ujs
#= require jquery.remotipart
#= require bootstrap
#= require accounting.js
#= require jquery-tokeninput
#
#= require procurement/bootstrap-multiselect
#
#= require_self

$(document).ready ->
  $('form').on('submit', ->
    $(this).find('.btn-success > i.fa.fa-check').removeClass('fa-check').addClass('fa-circle-o-notch spinner')
  ).on 'ajax:complete', ->
    $(this).find('.btn-success > i.fa.fa-circle-o-notch.spinner').removeClass('fa-circle-o-notch').removeClass('spinner').addClass('fa-check')


  $('body').on 'focus mouseover', '[data-toggle="tooltip"]', -> $(this).tooltip('toggle')
