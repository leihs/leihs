#####
#
# this manifest includes all javascript files that are used in both:
# the borrow section and the manage section of leihs
#
#= require_self
#
##### VENDOR
#
#= require jquery
#= require jquery_ujs
#= require jsrender
#= require underscore
#= require underscore/underscore.string
#= require underscore/underscore.each_slice
#= require bootstrap/bootstrap-modal
#= require bootstrap/bootstrap-dropdown
#= require tooltipster/tooltipster
#= require jquery.inview/jquery.inview
#= require jed/jed
#= require accounting/accounting
#= require moment/moment
#= require fullcalendar/fullcalendar
#= require URI.js/URI.js
#
##### JqueryUI
#
#= require jquery-ui/jquery.ui.core
#= require jquery-ui/jquery.ui.widget
#= require jquery-ui/jquery.ui.position
#= require jquery-ui/jquery.ui.mouse
#= require jquery-ui/jquery.ui.menu
#= require jquery-ui/jquery.ui.sortable
#= require jquery-ui/jquery.ui.datepicker
#= require jquery-ui/jquery.ui.autocomplete
#
##### SPINE
#
#= require spine/spine
#= require spine/manager
#= require spine/ajax
#= require spine/relation
#
##### APP
#
#= require_tree ./initalizers
#= require_tree ./lib
#= require_tree ./modules
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#
#####

window.App ?= {}
window.Tools ?= {}
window.App.Modules ?= {}
