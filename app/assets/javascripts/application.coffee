#####
#
# this manifest includes all javascript files that are used in both:
# the borrow section and the manage section of leihs
#
#= require_self
#
##### RAILS ASSETS
#
#= require jquery
#= require jquery-ui
#= require jquery-ujs
#= require jquery.inview
#= require moment
#= require accounting.js
#= require fullcalendar
#= require underscore
#= require uri.js
#
##### VENDOR
#
#= require jed/jed
#= require jsrender
#= require underscore/underscore.string
#= require underscore/underscore.each_slice
#= require bootstrap/bootstrap-modal
#= require bootstrap/bootstrap-dropdown
#= require tooltipster/tooltipster
#
##### SPINE
#
#= require spine/spine
#= require spine/manager
#= require spine/ajax
#= require spine/relation
#
##### REACT
#
#= require react
#= require components
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
