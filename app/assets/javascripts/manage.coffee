#####
#
# this manifest includes all javascript files that are used only
# in the manage section of leihs
#
##### VENDOR
#
#= require jqBarGraph/jqBarGraph.1.2
#= require format-number/format-number
#
##### APP
#
#= require_self
#
#= require_tree ./manage/lib
#= require_tree ./manage/modules
#= require_tree ./manage/models
#= require_tree ./manage/controllers
#= require_tree ./manage/views
#
#####
