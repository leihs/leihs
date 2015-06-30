/*globals Timecop*/

// A data class for carrying around 'time movement' objects.
// Makes it easy to keep track of the time movements on a simple stack.
Timecop.TimeStackItem = function(mockType, time) {
  if (mockType !== 'freeze' && mockType !== 'travel') {
    throw 'Unknown mock_type ' + mockType;
  }
  this.mockType = mockType;
  this._time = time;
  this._travelOffset = this._computeTravelOffset();
};

Timecop.TimeStackItem.prototype = {
  date: function() {
    return this.time();
  },

  time: function() {
    if (this._travelOffset === null) {
      return this._time;
    }
    // console.log('Now: ');
    return new Timecop.NativeDate((new Timecop.NativeDate()).getTime() + this._travelOffset);
  },

  // @api private
  // @return [Integer] millisecond offset traveled, if mockType is 'travel'
  _computeTravelOffset: function() {
    if (this.mockType === 'freeze') {
      return null;
    }
    return this._time.getTime() - (new Timecop.NativeDate()).getTime();
  }
};
