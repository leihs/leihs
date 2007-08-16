function checkSelectValue(inObj) {

  if (!inObj.options[inObj.options.selectedIndex].text) {
    inObj.options.selectedIndex = 0;
  }
}

function flipSlot(inId,inLine) {

  var bodyObj          = document.getElementById(inId + "body");
  var branchObj        = document.getElementById(inId + "branch");
  var iconObj          = document.getElementById(inId + "icon");
  var scrollcontentObj = document.getElementById("scrollcontent");
  var scrollpaneObj    = document.getElementById("scrollpane");
  
  if (bodyObj && branchObj && iconObj && scrollcontentObj && scrollpaneObj) {
  
    if (bodyObj.style.display != "none") {
      bodyObj.style.display = "none";
      branchObj.className   = "";
      iconObj.src           = "/images/ico_plus.gif";
    } else {
      bodyObj.style.display = "block";
      if (inLine) {
				branchObj.className   = "branchstart";
			}
      iconObj.src           = "/images/ico_minus.gif";
    }
    
    // BUGFIX FOR GECKO (provocate update of scrollcontent)
    scrollcontentObj.scrollTop = scrollcontentObj.scrollTop;
    scrollpaneObj.scrollTop    = scrollpaneObj.scrollTop;
  }
}

function flipItem(inId) {

  var obj              = document.getElementById(inId);
  var scrollcontentObj = document.getElementById("scrollcontent");
  var scrollpaneObj    = document.getElementById("scrollpane");
  
  if (obj && scrollcontentObj && scrollpaneObj) {
  
    if (obj.style.display != "none") {
      obj.style.display = "none";
    } else {
      obj.style.display = "block";
    }
    
    // BUGFIX FOR GECKO (provocate update of scrollcontent)
    scrollcontentObj.scrollTop = scrollcontentObj.scrollTop;
    scrollpaneObj.scrollTop    = scrollpaneObj.scrollTop;
  }
}

function flipSubSlot(inEl1,inEl2) {

  var el1              = document.getElementById(inEl1);
  var el2              = document.getElementById(inEl2);
  var scrollcontentObj = document.getElementById("scrollcontent");
  var scrollpaneObj    = document.getElementById("scrollpane");
  
  if (el1 && el2 && scrollcontentObj && scrollpaneObj) {
  
    if (el1.style.display != "none") {
      el1.style.display = "none";
      el2.style.display = "none";
    } else {
      el1.style.display = "";
      el2.style.display = "";
    }
    
    // BUGFIX FOR GECKO (provocate update of scrollcontent)
    scrollcontentObj.scrollTop = scrollcontentObj.scrollTop;
    scrollpaneObj.scrollTop    = scrollpaneObj.scrollTop;
  }
}



// BUGFIX FOR GECKO (calculate dynamic layout of scrollpane)
function arrangeScrollpane() {

  var scrollcontentObj = document.getElementById("scrollcontent");
  var scrollpaneObj    = document.getElementById("scrollpane");
  
  if (scrollpaneObj && window.innerHeight) {
    try {
      var aHeight = parseInt((window.innerHeight)?(window.innerHeight):(document.body.clientHeight)) -170;
      var aWidth  = parseInt((window.innerWidth)?(window.innerWidth):(document.body.clientWidth)) - 425;
      
      aWidth = (aWidth<450)?(450):(aWidth);
      
      scrollpaneObj.style.height = aHeight; 
      scrollpaneObj.style.width  = aWidth;
    } catch (e) {
    
    }
  }
}

window.onload   = arrangeScrollpane;
window.onresize = arrangeScrollpane;