###

  Group

  This script provides functionalities for groups
  
###

class Group

  @intersect_groups_and_partitions: (groups, partitions) ->
    if partitions.length == 0
      return []
    else if !groups? and !partitions?
      return false
    else
      group_ids = _.map groups, (g)-> g.id
      return _.filter partitions, (p)-> _.include(group_ids, p.group_id)

  @diff_groups_and_partitions: (groups, partitions)->
    if partitions.length == 0
      return groups
    else if !groups? and !partitions?
      return false
    else
      group_ids = _.map groups, (g)-> g.id
      return _.filter partitions, (p)-> !_.include(group_ids, p.group_id)

window.App.Group = Group