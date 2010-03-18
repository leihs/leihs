/*
Copyright (c) 2007 Brian Dillard and Brad Neuberg:
Brian Dillard | Project Lead | bdillard@pathf.com | http://blogs.pathf.com/agileajax/
Brad Neuberg | Original Project Creator | http://codinginparadise.org
   
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files
(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

/*
	dhtmlHistory: An object that provides history, history data, and bookmarking for DHTML and Ajax applications.
	
	dependencies:
		* the historyStorage object included in this file.

*/
window.dhtmlHistory = {
	
	/*Public: User-agent booleans*/
	isIE: false,
	isOpera: false,
	isSafari: false,
	isKonquerer: false,
	isGecko: false,
	isSupported: false,
	
	/*Public: Create the DHTML history infrastructure*/
	create: function(options) {
		
		/*
			options - object to store initialization parameters
			options.debugMode - boolean that causes hidden form fields to be shown for development purposes.
			options.toJSON - function to override default JSON stringifier
			options.fromJSON - function to override default JSON parser
		*/

		var that = this;

		/*set user-agent flags*/
		var UA = navigator.userAgent.toLowerCase();
		var platform = navigator.platform.toLowerCase();
		var vendor = navigator.vendor || "";
		if (vendor === "KDE") {
			this.isKonqueror = true;
			this.isSupported = false;
		} else if (typeof window.opera !== "undefined") {
			this.isOpera = true;
			this.isSupported = true;
		} else if (typeof document.all !== "undefined") {
			this.isIE = true;
			this.isSupported = true;
		} else if (vendor.indexOf("Apple Computer, Inc.") > -1) {
//			this.isSafari = true;
			this.isGecko = true;
			this.isSupported = (platform.indexOf("mac") > -1);
		} else if (UA.indexOf("gecko") != -1) {
			this.isGecko = true;
			this.isSupported = true;
		}

		/*Set up the historyStorage object; pass in init parameters*/
		window.historyStorage.setup(options);

		/*Execute browser-specific setup methods*/
		if (this.isSafari) {
			this.createSafari();
		} else if (this.isOpera) {
			this.createOpera();
		}
		
		/*Get our initial location*/
		var initialHash = this.getCurrentLocation();

		/*Save it as our current location*/
		this.currentLocation = initialHash;

		/*Now that we have a hash, create IE-specific code*/
		if (this.isIE) {
			this.createIE(initialHash);
		}

		/*Add an unload listener for the page; this is needed for FF 1.5+ because this browser caches all dynamic updates to the
		page, which can break some of our logic related to testing whether this is the first instance a page has loaded or whether
		it is being pulled from the cache*/

		var unloadHandler = function() {
			that.firstLoad = null;
		};
		
		this.addEventListener(window,'unload',unloadHandler);		

		/*Determine if this is our first page load; for IE, we do this in this.iframeLoaded(), which is fired on pageload. We do it
		there because we have no historyStorage at this point, which only exists after the page is finished loading in IE*/
		if (this.isIE) {
			/*The iframe will get loaded on page load, and we want to ignore this fact*/
			this.ignoreLocationChange = true;
		} else {
			if (!historyStorage.hasKey(this.PAGELOADEDSTRING)) {
				/*This is our first page load, so ignore the location change and add our special history entry*/
				this.ignoreLocationChange = true;
				this.firstLoad = true;
				historyStorage.put(this.PAGELOADEDSTRING, true);
			} else {
				/*This isn't our first page load, so indicate that we want to pay attention to this location change*/
				this.ignoreLocationChange = false;
				/*For browsers other than IE, fire a history change event; on IE, the event will be thrown automatically when its
				hidden iframe reloads on page load. Unfortunately, we don't have any listeners yet; indicate that we want to fire
				an event when a listener is added.*/
				this.fireOnNewListener = true;
			}
		}

		/*Other browsers can use a location handler that checks at regular intervals as their primary mechanism; we use it for IE as
		well to handle an important edge case; see checkLocation() for details*/
		var locationHandler = function() {
			that.checkLocation();
		};
		setInterval(locationHandler, 100);
	},	
	
	/*Public: Initialize our DHTML history. You must call this after the page is finished loading.*/
	initialize: function() {
		/*IE needs to be explicitly initialized. IE doesn't autofill form data until the page is finished loading, so we have to wait*/
		if (this.isIE) {
			/*If this is the first time this page has loaded*/
			if (!historyStorage.hasKey(this.PAGELOADEDSTRING)) {
				/*For IE, we do this in initialize(); for other browsers, we do it in create()*/
				this.fireOnNewListener = false;
				this.firstLoad = true;
				historyStorage.put(this.PAGELOADEDSTRING, true);
			}
			/*Else if this is a fake onload event*/
			else {
				this.fireOnNewListener = true;
				this.firstLoad = false;   
			}
		}
	},

	/*Public: Adds a history change listener. Note that only one listener is supported at this time.*/
	addListener: function(listener) {
		this.listener = listener;
		/*If the page was just loaded and we should not ignore it, fire an event to our new listener now*/
		if (this.fireOnNewListener) {
			this.fireHistoryEvent(this.currentLocation);
			this.fireOnNewListener = false;
		}
	},
	
	/*Public: Generic utility function for attaching events*/
	addEventListener: function(o,e,l) {
		if (o.addEventListener) {
			o.addEventListener(e,l,false);
		} else if (o.attachEvent) {
			o.attachEvent('on'+e,function() {
				l(window.event);
			});
		}
	},
	
	/*Public: Add a history point.*/
	add: function(newLocation, historyData) {
		
		if (this.isSafari) {
			
			/*Remove any leading hash symbols on newLocation*/
			newLocation = this.removeHash(newLocation);

			/*Store the history data into history storage*/
			historyStorage.put(newLocation, historyData);

			/*Save this as our current location*/
			this.currentLocation = newLocation;
	
			/*Change the browser location*/
			window.location.hash = newLocation;
		
			/*Save this to the Safari form field*/
			this.putSafariState(newLocation);

		} else {
			
			/*Most browsers require that we wait a certain amount of time before changing the location, such
			as 200 MS; rather than forcing external callers to use window.setTimeout to account for this,
			we internally handle it by putting requests in a queue.*/
			var that = this;
			var addImpl = function() {

				/*Indicate that the current wait time is now less*/
				if (that.currentWaitTime > 0) {
					that.currentWaitTime = that.currentWaitTime - that.waitTime;
				}
			
				/*Remove any leading hash symbols on newLocation*/
				newLocation = that.removeHash(newLocation);

				/*IE has a strange bug; if the newLocation is the same as _any_ preexisting id in the
				document, then the history action gets recorded twice; throw a programmer exception if
				there is an element with this ID*/
				if (document.getElementById(newLocation) && that.debugMode) {
					var e = "Exception: History locations can not have the same value as _any_ IDs that might be in the document,"
					+ " due to a bug in IE; please ask the developer to choose a history location that does not match any HTML"
					+ " IDs in this document. The following ID is already taken and cannot be a location: " + newLocation;
					throw new Error(e); 
				}

				/*Store the history data into history storage*/
				historyStorage.put(newLocation, historyData);

				/*Indicate to the browser to ignore this upcomming location change since we're making it programmatically*/
				that.ignoreLocationChange = true;

				/*Indicate to IE that this is an atomic location change block*/
				that.ieAtomicLocationChange = true;

				/*Save this as our current location*/
				that.currentLocation = newLocation;
		
				/*Change the browser location*/
				window.location.hash = newLocation;

				/*Change the hidden iframe's location if on IE*/
				if (that.isIE) {
					that.iframe.src = "/blank.html?" + newLocation;
				}

				/*End of atomic location change block for IE*/
				that.ieAtomicLocationChange = false;
			};

			/*Now queue up this add request*/
			window.setTimeout(addImpl, this.currentWaitTime);

			/*Indicate that the next request will have to wait for awhile*/
			this.currentWaitTime = this.currentWaitTime + this.waitTime;
		}
	},

	/*Public*/
	isFirstLoad: function() {
		return this.firstLoad;
	},

	/*Public*/
	getVersion: function() {
		return "0.6";
	},

	/*Get browser's current hash location; for Safari, read value from a hidden form field*/

	/*Public*/
	getCurrentLocation: function() {
		var r = (this.isSafari
			? this.getSafariState()
			: this.getCurrentHash()
		);
		return r;
	},
	
	/*Public: Manually parse the current url for a hash; tip of the hat to YUI*/
    getCurrentHash: function() {
		var r = window.location.href;
		var i = r.indexOf("#");
		return (i >= 0
			? r.substr(i+1)
			: ""
		);
    },
	
	/*- - - - - - - - - - - -*/
	
	/*Private: Constant for our own internal history event called when the page is loaded*/
	PAGELOADEDSTRING: "DhtmlHistory_pageLoaded",
	
	/*Private: Our history change listener.*/
	listener: null,

	/*Private: MS to wait between add requests - will be reset for certain browsers*/
	waitTime: 200,
	
	/*Private: MS before an add request can execute*/
	currentWaitTime: 0,

	/*Private: Our current hash location, without the "#" symbol.*/
	currentLocation: null,

	/*Private: Hidden iframe used to IE to detect history changes*/
	iframe: null,

	/*Private: Flags and DOM references used only by Safari*/
	safariHistoryStartPoint: null,
	safariStack: null,
	safariLength: null,

	/*Private: Flag used to keep checkLocation() from doing anything when it discovers location changes we've made ourselves
	programmatically with the add() method. Basically, add() sets this to true. When checkLocation() discovers it's true,
	it refrains from firing our listener, then resets the flag to false for next cycle. That way, our listener only gets fired on
	history change events triggered by the user via back/forward buttons and manual hash changes. This flag also helps us set up
	IE's special iframe-based method of handling history changes.*/
	ignoreLocationChange: null,

	/*Private: A flag that indicates that we should fire a history change event when we are ready, i.e. after we are initialized and
	we have a history change listener. This is needed due to an edge case in browsers other than IE; if you leave a page entirely
	then return, we must fire this as a history change event. Unfortunately, we have lost all references to listeners from earlier,
	because JavaScript clears out.*/
	fireOnNewListener: null,

	/*Private: A variable that indicates whether this is the first time this page has been loaded. If you go to a web page, leave it
	for another one, and then return, the page's onload listener fires again. We need a way to differentiate between the first page
	load and subsequent ones. This variable works hand in hand with the pageLoaded variable we store into historyStorage.*/
	firstLoad: null,

	/*Private: A variable to handle an important edge case in IE. In IE, if a user manually types an address into their browser's
	location bar, we must intercept this by calling checkLocation() at regular intervals. However, if we are programmatically
	changing the location bar ourselves using the add() method, we need to ignore these changes in checkLocation(). Unfortunately,
	these changes take several lines of code to complete, so for the duration of those lines of code, we set this variable to true.
	That signals to checkLocation() to ignore the change-in-progress. Once we're done with our chunk of location-change code in
	add(), we set this back to false. We'll do the same thing when capturing user-entered address changes in checkLocation itself.*/
	ieAtomicLocationChange: null,
	
	/*Private: Create IE-specific DOM nodes and overrides*/
	createIE: function(initialHash) {
		/*write out a hidden iframe for IE and set the amount of time to wait between add() requests*/
		this.waitTime = 400;/*IE needs longer between history updates*/
		var styles = (historyStorage.debugMode
			? 'width: 800px;height:80px;border:1px solid black;'
			: historyStorage.hideStyles
		);
		var iframeID = "rshHistoryFrame";
		var iframeHTML = '<iframe frameborder="0" id="' + iframeID + '" style="' + styles + '" src="/blank.html?' + initialHash + '"></iframe>';
		document.write(iframeHTML);
		this.iframe = document.getElementById(iframeID);
	},
	
	/*Private: Create Opera-specific DOM nodes and overrides*/
	createOpera: function() {
		this.waitTime = 400;/*Opera needs longer between history updates*/
		var imgHTML = '<img src="javascript:location.href=\'javascript:dhtmlHistory.checkLocation();\';" style="' + historyStorage.hideStyles + '" />';
		document.write(imgHTML);
	},
	
	/*Private: Create Safari-specific DOM nodes and overrides*/
	createSafari: function() {
		var formID = "rshSafariForm";
		var stackID = "rshSafariStack";
		var lengthID = "rshSafariLength";
		var formStyles = historyStorage.debugMode ? historyStorage.showStyles : historyStorage.hideStyles;
		var inputStyles = (historyStorage.debugMode
			? 'width:800px;height:20px;border:1px solid black;margin:0;padding:0;'
			: historyStorage.hideStyles
		);
		var safariHTML = '<form id="' + formID + '" style="' + formStyles + '">'
			+ '<input type="text" style="' + inputStyles + '" id="' + stackID + '" value="[]"/>'
			+ '<input type="text" style="' + inputStyles + '" id="' + lengthID + '" value=""/>'
		+ '</form>';
		document.write(safariHTML);
		this.safariStack = document.getElementById(stackID);
		this.safariLength = document.getElementById(lengthID);
		if (!historyStorage.hasKey(this.PAGELOADEDSTRING)) {
			this.safariHistoryStartPoint = history.length;
			this.safariLength.value = this.safariHistoryStartPoint;
		} else {
			this.safariHistoryStartPoint = this.safariLength.value;
		}
	},
	
	/*Private: Safari method to read the history stack from a hidden form field*/
	getSafariStack: function() {
		var r = this.safariStack.value;
		return historyStorage.fromJSON(r);
	},

	/*Private: Safari method to read from the history stack*/
	getSafariState: function() {
		var stack = this.getSafariStack();
		var state = stack[history.length - this.safariHistoryStartPoint - 1];
		return state;
	},			
	/*Private: Safari method to write the history stack to a hidden form field*/
	putSafariState: function(newLocation) {
	    var stack = this.getSafariStack();
	    stack[history.length - this.safariHistoryStartPoint] = newLocation;
	    this.safariStack.value = historyStorage.toJSON(stack);
	},

	/*Private: Notify the listener of new history changes.*/
	fireHistoryEvent: function(newHash) {
		/*extract the value from our history storage for this hash*/
		var historyData = historyStorage.get(newHash);
		/*call our listener*/
		this.listener.call(null, newHash, historyData);
	},
	
	/*Private: See if the browser has changed location. This is the primary history mechanism for Firefox. For IE, we use this to
	handle an important edge case: if a user manually types in a new hash value into their IE location bar and press enter, we want to
	to intercept this and notify any history listener.*/
	checkLocation: function() {
		
		/*Ignore any location changes that we made ourselves for browsers other than IE*/
		if (!this.isIE && this.ignoreLocationChange) {
			this.ignoreLocationChange = false;
			return;
		}

		/*If we are dealing with IE and we are in the middle of making a location change from an iframe, ignore it*/
		if (!this.isIE && this.ieAtomicLocationChange) {
			return;
		}
		
		/*Get hash location*/
		var hash = this.getCurrentLocation();

		/*Do nothing if there's been no change*/
		if (hash == this.currentLocation) {
			return;
		}

		/*In IE, users manually entering locations into the browser; we do this by comparing the browser's location against the
		iframe's location; if they differ, we are dealing with a manual event and need to place it inside our history, otherwise
		we can return*/
		this.ieAtomicLocationChange = true;

		if (this.isIE && this.getIframeHash() != hash) {
			this.iframe.src = "/blank.html?" + hash;
		}
		else if (this.isIE) {
			/*the iframe is unchanged*/
			return;
		}

		/*Save this new location*/
		this.currentLocation = hash;

		this.ieAtomicLocationChange = false;

		/*Notify listeners of the change*/
		this.fireHistoryEvent(hash);
	},

	/*Private: Get the current location of IE's hidden iframe.*/
	getIframeHash: function() {
		var doc = this.iframe.contentWindow.document;
		var hash = String(doc.location.search);
		if (hash.length == 1 && hash.charAt(0) == "?") {
			hash = "";
		}
		else if (hash.length >= 2 && hash.charAt(0) == "?") {
			hash = hash.substring(1);
		}
		return hash;
	},

	/*Private: Remove any leading hash that might be on a location.*/
	removeHash: function(hashValue) {
		var r;
		if (hashValue === null || hashValue === undefined) {
			r = null;
		}
		else if (hashValue === "") {
			r = "";
		}
		else if (hashValue.length == 1 && hashValue.charAt(0) == "#") {
			r = "";
		}
		else if (hashValue.length > 1 && hashValue.charAt(0) == "#") {
			r = hashValue.substring(1);
		}
		else {
			r = hashValue;
		}
		return r;
	},

	/*Private: For IE, tell when the hidden iframe has finished loading.*/
	iframeLoaded: function(newLocation) {
		/*ignore any location changes that we made ourselves*/
		if (this.ignoreLocationChange) {
			this.ignoreLocationChange = false;
			return;
		}

		/*Get the new location*/
		var hash = String(newLocation.search);
		if (hash.length == 1 && hash.charAt(0) == "?") {
			hash = "";
		}
		else if (hash.length >= 2 && hash.charAt(0) == "?") {
			hash = hash.substring(1);
		}
		/*Keep the browser location bar in sync with the iframe hash*/
		window.location.hash = hash;

		/*Notify listeners of the change*/
		this.fireHistoryEvent(hash);
	}

};

/*
	historyStorage: An object that uses a hidden form to store history state across page loads. The mechanism for doing so relies on
	the fact that browsers save the text in form data for the life of the browser session, which means the text is still there when
	the user navigates back to the page. This object can be used independently of the dhtmlHistory object for caching of Ajax
	session information.
	
	dependencies: 
		* json2007.js (included in a separate file) or alternate JSON methods passed in through an options bundle.
*/
window.historyStorage = {
	
	/*Public: Set up our historyStorage object for use by dhtmlHistory or other objects*/
	setup: function(options) {
		
		/*
			options - object to store initialization parameters - passed in from dhtmlHistory or directly into historyStorage
			options.debugMode - boolean that causes hidden form fields to be shown for development purposes.
			options.toJSON - function to override default JSON stringifier
			options.fromJSON - function to override default JSON parser
		*/
		
		/*process init parameters*/
		if (typeof options !== "undefined") {
			if (options.debugMode) {
				this.debugMode = options.debugMode;
			}
			if (options.toJSON) {
				this.toJSON = options.toJSON;
			}
			if (options.fromJSON) {
				this.fromJSON = options.fromJSON;
			}
		}		
		
		/*write a hidden form and textarea into the page; we'll stow our history stack here*/
		var formID = "rshStorageForm";
		var textareaID = "rshStorageField";
		var formStyles = this.debugMode ? historyStorage.showStyles : historyStorage.hideStyles;
		var textareaStyles = (historyStorage.debugMode
			? 'width: 800px;height:80px;border:1px solid black;'
			: historyStorage.hideStyles
		);
		var textareaHTML = '<form id="' + formID + '" style="' + formStyles + '">'
			+ '<textarea id="' + textareaID + '" style="' + textareaStyles + '"></textarea>'
		+ '</form>';
		document.write(textareaHTML);
		this.storageField = document.getElementById(textareaID);
		if (typeof window.opera !== "undefined") {
			this.storageField.focus();/*Opera needs to focus this element before persisting values in it*/
		}
	},
	
	/*Public*/
	put: function(key, value) {
		this.assertValidKey(key);
		/*if we already have a value for this, remove the value before adding the new one*/
		if (this.hasKey(key)) {
			this.remove(key);
		}
		/*store this new key*/
		this.storageHash[key] = value;
		/*save and serialize the hashtable into the form*/
		this.saveHashTable();
	},

	/*Public*/
	get: function(key) {
		this.assertValidKey(key);
		/*make sure the hash table has been loaded from the form*/
		this.loadHashTable();
		var value = this.storageHash[key];
		if (value === undefined) {
			value = null;
		}
		return value;
	},

	/*Public*/
	remove: function(key) {
		this.assertValidKey(key);
		/*make sure the hash table has been loaded from the form*/
		this.loadHashTable();
		/*delete the value*/
		delete this.storageHash[key];
		/*serialize and save the hash table into the form*/
		this.saveHashTable();
	},

	/*Public: Clears out all saved data.*/
	reset: function() {
		this.storageField.value = "";
		this.storageHash = {};
	},

	/*Public*/
	hasKey: function(key) {
		this.assertValidKey(key);
		/*make sure the hash table has been loaded from the form*/
		this.loadHashTable();
		return (typeof this.storageHash[key] !== "undefined");
	},

	/*Public*/
	isValidKey: function(key) {
		return (typeof key === "string");
	},
	
	/*Public - CSS strings utilized by both objects to hide or show behind-the-scenes DOM elements*/
	showStyles: 'border:0;margin:0;padding:0;',
	hideStyles: 'left:-1000px;top:-1000px;width:1px;height:1px;border:0;position:absolute;',
	
	/*Public - debug mode flag*/
	debugMode: false,
	
	/*- - - - - - - - - - - -*/

	/*Private: Our hash of key name/values.*/
	storageHash: {},

	/*Private: If true, we have loaded our hash table out of the storage form.*/
	hashLoaded: false, 

	/*Private: DOM reference to our history field*/
	storageField: null,

	/*Private: Assert that a key is valid; throw an exception if it not.*/
	assertValidKey: function(key) {
		var isValid = this.isValidKey(key);
		if (!isValid && this.debugMode) {
			throw new Error("Please provide a valid key for window.historyStorage. Invalid key = " + key + ".");
		}
	},

	/*Private: Load the hash table up from the form.*/
	loadHashTable: function() {
		if (!this.hashLoaded) {	
			var serializedHashTable = this.storageField.value;
			if (serializedHashTable !== "" && serializedHashTable !== null) {
				this.storageHash = this.fromJSON(serializedHashTable);
				this.hashLoaded = true;
			}
		}
	},
	/*Private: Save the hash table into the form.*/
	saveHashTable: function() {
		this.loadHashTable();
		var serializedHashTable = this.toJSON(this.storageHash);
		this.storageField.value = serializedHashTable;
	},
	/*Private: Bridges for our JSON implementations - both rely on 2007 JSON.org library - can be overridden by options bundle*/
	toJSON: function(o) {
		return o.toJSONString();
	},
	fromJSON: function(s) {
		return s.parseJSON();
	}
};
