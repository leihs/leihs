#####
#
# this manifest includes all javascript files that are used only
# in the manage section of leihs
#
##### VENDOR
#
#= require jqBarGraph/jqBarGraph.1.2
#= require jquery-autosize/jquery.autosize
#
##### APP
#
#= require_self
#
#= require ./upload
#
#= require_tree ./manage/lib
#= require_tree ./manage/modules
#= require_tree ./manage/models
#= require_tree ./manage/controllers
#= require_tree ./manage/views
#
#####
