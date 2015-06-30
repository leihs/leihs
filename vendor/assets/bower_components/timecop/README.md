## What ##

A port of John Trupiano's awesome
[Timecop](https://github.com/travisjeffery/timecop)
Ruby to Javascript.

## How ##

Call `Timecop.install()` once to get started. This replaces `Date` with
`Timecop.MockDate`. After that, you can travel through time at will.

Travel to the morning of October 17, 2010, and allow time to continue advancing:

``` javascript
Timecop.travel(new Date(2010, 10, 17, 11, 45));
```

Travel to the afternoon of January 21, 2012, and keep time frozen then:

``` javascript
Timecop.freeze(new Date(2012, 1, 21, 14, 30));
```

Return to the present:

``` javascript
Timecop.returnToPresent();
```

Finally, to uninstall Timecop and reinstate the native Date constructor:

``` javascript
Timecop.uninstall();
```

## Contributing ##

For bug reports, open an [issue](https://github.com/jamesarosen/Timecop.js/issues)
on GitHub.

Timecop.js has a ‘commit-bit’ policy, much like the Rubinius project
and Gemcutter. Submit a patch that is accepted, and you can get full
commit access to the project. All you have to do is open an issue
asking for access and I'll add you as a collaborator.
Feel free to fork the project though and have fun in your own sandbox.

Code style:

 * 2 space indent
 * all conditional and loop blocks have `{ }`
 * not picky about spaces around arguments
 * all code must pass JSLint with fairly strict settings
