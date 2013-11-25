/**
  * Underscore.js mixin to emulate Ruby's Enumerable#each_slice method.
  * http://www.ruby-doc.org/core/classes/Enumerable.html#M001514
  *
  */
 
_.mixin({
  each_slice: function(obj, slice_size, iterator, context) {
    var collection = obj.map(function(item) { return item; });
    
    if (typeof collection.slice !== 'undefined') {
      for (var i = 0, s = Math.ceil(collection.length/slice_size); i < s; i++) {
        iterator.call(context, _(collection).slice(i*slice_size, (i*slice_size)+slice_size), obj);
      }
    }
    return; 
  }
});
 
/* Example:
 
>>> _([1,2,3,4,5,6,7,8,9,10]).each_slice(4, function(slice) { console.log(slice); })
[1, 2, 3, 4]
[5, 6, 7, 8]
[9, 10]
 
*/