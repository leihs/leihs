window.App.ElementFormDataAsObject = (el)->
  data = {}
  for datum in $("<form></form>").html(el.clone()).serializeArray()
    name = datum.name.replace(/^\w+\[.*?\]\[.*?\]/, "")
    keys = _.compact name.match(/(?!\[).*?(?=\])/g)
    _.reduce keys, (hash, key) -> 
      hash[key] ||= {}
      if _.last(keys) == key # reached the end
        if Array.isArray(hash) # array already exists just push the data
          add = {}
          add[key] = datum.value
          hash.push add
        else if _.size(hash[key]) != 0 # value exists, force an array
          initalizeArray keys, key, datum, data
        else
          hash[key] = datum.value
      return hash[key]
    , data
  data

initalizeArray = (keys, key, datum, data)->
  keys = keys.splice(0,keys.length-1)
  _.reduce keys, (h, k)->
    if _.last(keys) == k
      add = {}
      add[key] = datum.value
      h[k] = [h[k], add]
    return h[k]
  , data