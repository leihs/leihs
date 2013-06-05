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
#= require jquery-ui
#= require jquery_ujs
#= require jsrender
#= require underscore
#= require bootstrap/bootstrap-modal
#= require tooltipster/tooltipster
#=
##### SPINE
#
#= require spine/spine
#= require spine/manager
#= require spine/ajax
#= require spine/relation
#
##### LIB
#
#= require_tree ./_NEW/lib
#= require_tree ./_NEW/modules
#= require_tree ./_NEW/models
#= require_tree ./_NEW/views
#
#####

window.App ?= {}
window.App.Modules ?= {}