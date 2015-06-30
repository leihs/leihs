describe('Timecop', function() {

  beforeEach(function() {
    Timecop.install();
  });

  afterEach(function() {
    Timecop.returnToPresent();
    Timecop.uninstall();
  });

  it('should exist', function() {
    expect(typeof(Timecop)).not.toEqual('undefined');
  });

  it('should have a public API', function() {
    expect(Timecop).toHaveFunction('travel');
    expect(Timecop).toHaveFunction('freeze');
    expect(Timecop).toHaveFunction('returnToPresent');
    expect(Timecop).toHaveFunction('topOfStack');
    expect(Timecop).toHaveFunction('buildNativeDate');
  });

  describe('.travel', function() {

    describe('with a date spelled out in numbers as arguments', function() {
      var someTimeIn2008 = new Timecop.NativeDate(2008, 6, 5, 14, 30, 15, 450);
      beforeEach(function() {
        Timecop.travel(someTimeIn2008);
      });

      it('should leave time running', function() {
        var self = this;
        var date1 = new Date();
        setTimeout(function() {
          var date2 = new Date();
          expect(date2.getTime() - date1.getTime()).toBeGreaterThan(200);
          expect(date2.getTime() - date1.getTime()).toBeLessThan(400);
          self.timePassed = true;
        }, 300);
        waitsFor(function() { return self.timePassed; }, 'some time to have passed', 500);
      });

      it('should change the time of dates created without any arguments', function() {
        expect(new Date()).toBeCloseInTimeTo(someTimeIn2008);
      });

      it('should not change the dates created with arguments', function() {
        var date = new Date(1999, 8, 24);
        expect(date.getFullYear()).toEqual(1999);
        expect(date.getMonth()   ).toEqual(8);
        expect(date.getDate()    ).toEqual(24);
      });
    });

    describe('when given a Date as an argument', function() {
      var independenceDay = new Timecop.NativeDate(1776, 6, 4);
      beforeEach(function() {
        Timecop.travel(independenceDay);
      });
      it('should travel to that Date', function() {
        expect(new Date()).toBeCloseInTimeTo(independenceDay);
      });
    });

    describe('when given a parseable String as an argument', function() {
      var turnOfMillennium = new Timecop.NativeDate(2000, 0, 1);
      beforeEach(function() {
        Timecop.travel(turnOfMillennium.toString());
      });
      it('should travel to that Date', function() {
        expect(new Date()).toBeCloseInTimeTo(turnOfMillennium);
      });
    });

    describe('when given a non-parseable String as an argument', function() {
      it('should throw an exception', function() {
        var badDate = 'ioankl ajfklja';
        expect(function() {
          Timecop.travel(badDate);
        }).toThrow('Could not parse date: "' + badDate + '"');
      });
    });

    describe('with a function as the last argument', function() {
      var duringTrip;

      beforeEach(function() {
        Timecop.travel(1901, 1, 2, function() {
          duringTrip = new Date();
        });
      });

      it('should evaluate the function in the given time', function() {
        expect(duringTrip).toBeCloseInTimeTo(new Date(1901, 1, 2));
      });

      it('should automatically return to the present', function() {
        expect(Timecop.topOfStack()).toBeNull();
      });
    });

  }); // Timecop.travel

  describe('.freeze', function() {

    describe('with a date spelled out in numbers as arguments', function() {
      beforeEach(function() {
        Timecop.freeze(2008, 6, 5, 14, 30, 15, 450);
      });

      it('should stop time', function() {
        var self = this;
        var date1 = new Date();
        setTimeout(function() {
          var date2 = new Date();
          expect(date2).toBeTheSameTimeAs(date1);
          self.timePassed = true;
        }, 300);
        waitsFor(function() { return self.timePassed; }, 'some time to have passed', 500);
      });
    });

    describe('with a function as the last argument', function() {
      var duringTrip;

      beforeEach(function() {
        Timecop.freeze(1864, 4, 22, function() {
          duringTrip = new Date();
        });
      });

      it('should evaluate the function in the given time', function() {
        expect(duringTrip).toBeCloseInTimeTo(new Date(1864, 4, 22));
      });

      it('should automatically return to the present', function() {
        expect(Timecop.topOfStack()).toBeNull();
      });
    });

  }); // Timecop.freeze

  describe('.return', function() {
    it('should return to the present regardless of the size of the Timecop stack', function() {
      var beforeLeave = new Date();
      Timecop.travel(1982, 7,  8);
      Timecop.freeze(1969, 9,  10);
      Timecop.travel(2004, 11, 12);
      Timecop.returnToPresent();
      var afterReturn = new Date();
      expect(afterReturn).toBeCloseInTimeTo(beforeLeave);
    });
  });

});
