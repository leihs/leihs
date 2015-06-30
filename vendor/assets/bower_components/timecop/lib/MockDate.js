/*globals Timecop*/

// A mock Date implementation.
Timecop.MockDate = function() {
  if (arguments.length > 0 || !Timecop.topOfStack()) {
    this._underlyingDate = Timecop.buildNativeDate.apply(Timecop, Array.prototype.slice.apply(arguments));
  } else {
    this._underlyingDate = Timecop.topOfStack().date();
  }
};

Timecop.MockDate.UTC = function() {
  return Timecop.NativeDate.UTC.apply(Timecop.NativeDate, arguments);
};

Timecop.MockDate.parse = function(dateString) {
  return Timecop.NativeDate.parse(dateString);
};

Timecop.MockDate.prototype = {};

// Delegate `method` to the underlying date,
// passing all arguments and returning the result.
function defineDelegate(method) {
  Timecop.MockDate.prototype[method] = function() {
    return this._underlyingDate[method].apply(this._underlyingDate, arguments);
  };
}

defineDelegate('toDateString');
defineDelegate('toGMTString');
defineDelegate('toISOString');
defineDelegate('toJSON');
defineDelegate('toLocaleDateString');
defineDelegate('toLocaleString');
defineDelegate('toLocaleTimeString');
defineDelegate('toString');
defineDelegate('toTimeString');
defineDelegate('toUTCString');
defineDelegate('valueOf');

var delegatedAspects = [
    'Date', 'Day', 'FullYear', 'Hours', 'Milliseconds', 'Minutes', 'Month',
    'Seconds', 'Time', 'TimezoneOffset', 'UTCDate', 'UTCDay',
    'UTCFullYear', 'UTCHours', 'UTCMilliseconds', 'UTCMinutes',
    'UTCMonth', 'UTCSeconds', 'Year'
  ],
  delegatedActions = [ 'get', 'set' ];

for (var i = 0; i < delegatedActions.length; i++) {
  for (var j = 0; j < delegatedAspects.length; j++) {
    defineDelegate(delegatedActions[i] + delegatedAspects[j]);
  }
}
