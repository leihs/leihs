describe('Timecop.MockDate', function() {

  var now, date;

  beforeEach(function() {
    now = new Date();
    Timecop.install();
  });

  afterEach(function() {
    Timecop.returnToPresent();
    Timecop.uninstall();
  });

  it('delegates the class method UTC to Timecop.NativeDate', function() {
    var nativeUTC = Timecop.NativeDate.UTC(2012, 12, 20, 14, 44),
        mockUTC   = Timecop.MockDate.UTC(2012, 12, 20, 14, 44);
    expect(mockUTC).toEqual(nativeUTC);
  });

  describe('when created in the present without arguments', function() {
    beforeEach(function() {
      date = new Timecop.MockDate();
    });

    it('should be about the same as now', function() {
      expect(date).toBeCloseInTimeTo(now);
    });
  });

  describe('when created while time traveling to the past without arguments', function() {
    beforeEach(function() {
      Timecop.travel(1980, 4, 29);
      date = new Timecop.MockDate();
    });

    it('should be in the past', function() {
      expect(date.getFullYear()).toEqual(1980);
    });

    it('should stay in the past even after we return to the present', function() {
      Timecop.returnToPresent();
      expect(date.getFullYear()).toEqual(1980);
    });
  });

  describe('when created with year, month, date', function() {
    beforeEach(function() {
      date = new Timecop.MockDate(1838, 8, 18, 16, 45);
    });

    it('should ignore our time travels', function() {
      expect(date.getFullYear()).toEqual(1838);
      Timecop.travel(1945, 5, 6);
      expect(date.getFullYear()).toEqual(1838);
      Timecop.returnToPresent();
      expect(date.getFullYear()).toEqual(1838);
    });
  });

  it('has setters', function() {
    [
      'Date', 'Day', 'FullYear', 'Hours', 'Milliseconds', 'Minutes', 'Month',
    'Seconds', 'Time', 'TimezoneOffset', 'UTCDate', 'UTCDay',
      'UTCFullYear', 'UTCHours', 'UTCMilliseconds', 'UTCMinutes',
      'UTCMonth', 'UTCSeconds', 'Year'
    ].forEach(function(aspect) {
      expect(date).toHaveFunction('set' + aspect);
    });
  });

  it('proxies setters to the underlying date', function() {
    date = new Timecop.MockDate();
    date.setFullYear(1838);
    expect(date.getFullYear()).toEqual(1838);
  });

  it('proxies to* to the underlying date', function() {
    date = new Timecop.MockDate();
    [
      'toDateString', 'toGMTString', 'toISOString', 'toJSON',
      'toLocaleDateString', 'toLocaleString', 'toLocaleTimeString', 'toString',
      'toTimeString', 'toUTCString'
    ].forEach(function(method) {
      expect(date).toHaveFunction(method);
    });
  });

});
