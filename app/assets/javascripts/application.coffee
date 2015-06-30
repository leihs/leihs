#####
#
# this manifest includes all javascript files that are used in both:
# the borrow section and the manage section of leihs
#
#= require_self
#
##### BOWER COMPONENTS
#
#= require jquery/dist/jquery
#= require jquery-ujs/src/rails
#= require accounting.js/accounting
#= require moment/moment
#= require fullcalendar/fullcalendar
#= require jquery.inview/jquery.inview
#= require uri.js/src/URI
#
##### VENDOR
#
#= require jed/jed
#= require jquery-ui
#= require jsrender
#= require underscore
#= require underscore/underscore.string
#= require underscore/underscore.each_slice
#= require bootstrap/bootstrap-modal
#= require bootstrap/bootstrap-dropdown
#= require tooltipster/tooltipster
#
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
