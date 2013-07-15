#####
#
# this manifest includes all javascript files that are used only
# in the borrow section of leihs
#
#= require_self
#
#= require_tree ./_NEW/borrow/lib
#= require_tree ./_NEW/borrow/models
#= require_tree ./_NEW/borrow/controllers
#= require_tree ./_NEW/borrow/views
#
#####

window.App.Borrow ?= {}