###

  Partition
  
###

class Partition

  @split_partitions_over_groups: (partitions, groups) ->
    _return = {included: [], not_included: []}
    partitions = _.reject partitions, (p)-> return not p.group_id? or p.group_id == 0 # we exclude the partition for the general group
    group_ids = _.map groups, (g)-> g.id
    _return.included = _.filter partitions, (p)-> return _.include group_ids, p.group_id
    _return.not_included = _.filter partitions, (p)-> return not _.include group_ids, p.group_id
    return _return

window.App.Partition = Partition