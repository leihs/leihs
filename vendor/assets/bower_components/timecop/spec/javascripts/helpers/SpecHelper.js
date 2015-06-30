beforeEach(function() {
  this.addMatchers({
    toHaveFunction: function(methodName) {
      return jQuery.isFunction(this.actual[methodName]);
    },

    toBeCloseInTimeTo: function(otherDate, delta) {
      delta = delta || 500;
      return otherDate.getTime() - delta <= this.actual.getTime() &&
             otherDate.getTime() + delta >= this.actual.getTime();
    },

    toBeTheSameTimeAs: function(otherDate) {
      return otherDate.getTime() === this.actual.getTime();
    }
  });
});
