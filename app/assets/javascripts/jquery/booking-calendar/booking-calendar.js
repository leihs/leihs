/*
 * Booking-Calendar
 *
 * This script setups the jquery FullCalendar plugin and adds
 * additional features for booking/renting processes
 *
 * @name Booking-Calendar
*/

$(document).ready(function(){
  
	BookingCalendar.setup();
	
});

var BookingCalendar = new BookingCalendar();

function BookingCalendar() {
  
    this.calendar // an instance of the fullcalendar
    
    this.oneDay = 86404000; // in milliseconds
    
    this.local;
    
    this.start_date = new Date();
    this.end_date = new Date(this.start_date.getTime() + this.oneDay);
    
    this.dragging = false;
    this.dragging_target;
    
    this.setup = function() {
      
      this.setupFromStorage();
      
      this.setupSelection();
      
      this.setupWindowEvents();
      
      this.setupLocal();
      
      this.setupFullcalendar();
      
      this.setupQuantity();
      
      this.localizeDates();
      
      this.setupDateRange();
      
      this.setupStartDate();
      
      this.setupEndDate();
      
      this.setupInventoryPoolSelector();
      
    	this.setAvDates(true);
    	
    	this.setupRightTail();
    	
      this.setupLeftTail();
    	
    	this.setupDayCells();
    	
    	this.disableTextSelection();
    	
    	this.closedDayStartValidation();
    }
    
    this.setupFromStorage = function() {
      if(sessionStorage.start_date && sessionStorage.end_date) {
        $("#book #start_date").val(JSON.parse(sessionStorage.start_date));
        $("#book #end_date").val(JSON.parse(sessionStorage.end_date));
      }
    }
    
    this.closedDayStartValidation = function() {
      BookingCalendar.moveForwardUntilOpend($("#book .date #start_date"));
      BookingCalendar.moveForwardUntilOpend($("#book .date #end_date"));
    }
    
    this.setupWindowEvents = function() {
      $(window).resize(function(){
        BookingCalendar.posLeftTail();
        BookingCalendar.posRightTail();
      });
      
      $(window).scroll(function(){
        BookingCalendar.posLeftTail();
        BookingCalendar.posRightTail();
      });
    }
    
    this.setupDayCells = function() {
      
      BookingCalendar.calendar.find(".fc-widget-content").live("mouseenter", function(event){
        
        if(BookingCalendar.dragging && BookingCalendar.dragging_target) {
          var offset = (BookingCalendar.dragging_target.attr("id") == "end_date") ? (5000 - BookingCalendar.oneDay) : BookingCalendar.oneDay;
          var date = new Date(BookingCalendar.getDateByElement(this).getTime() + offset);
          $(BookingCalendar.dragging_target).val(formatDate(date, BookingCalendar.local.dateFormat));
          $(BookingCalendar.dragging_target).change();
        }
      });
    }
    
    this.setupLeftTail = function() {
      
      $("body").append('<div id="calendar-tail-left" class="calendar-tail"></div>');
      this.posLeftTail(); this.posLeftTail(); //have to call it twice for perfect positioning
      
       // MOUSE ENTER
     
      $("#calendar-tail-left").live("mouseenter", function() {
        $(this).css("cursor", "move");
      });
     
      // MOUSE LEAVE
     
      $("#calendar-tail-left").live("mouseleave", function() {
        $(this).css("cursor", "auto");
      });
     
      // MOUSE DOWN 
      
      $("#calendar-tail-left").live("mousedown", function() {
        
        BookingCalendar.startDraggingFor($("#book #start_date"));
        
        $("html, body").css("cursor", "move");
        $(this).css("cursor", "auto");
        
        $(window).bind("mouseup", function() {
          
          BookingCalendar.stopDragging();
          
          $(window).unbind("mouseup");
          $("html, body").css("cursor", "auto");
        });
      });
    }
    
    this.posLeftTail = function() {
      $("#calendar-tail-left").position({
          "my": "right center",
          "at": "left center",
          "of": $("#fullcalendar .start-date")
      }).show();
    }
    
    this.setupRightTail = function() {
      
      $("body").append('<div id="calendar-tail-right" class="calendar-tail"></div>');
      this.posRightTail(); this.posRightTail(); //have to call it twice for perfect positioning
      
       // MOUSE ENTER
     
      $("#calendar-tail-right").live("mouseenter", function(event) {
        $(this).css("cursor", "move");
      });
     
      // MOUSE LEAVE
     
      $("#calendar-tail-right").live("mouseleave", function() {
        $(this).css("cursor", "auto");
      });
     
      // MOUSE DOWN 
      
      $("#calendar-tail-right").live("mousedown", function() {
        
        BookingCalendar.startDraggingFor($("#book #end_date"));
        
        $("html, body").css("cursor", "move");
        $(this).css("cursor", "auto");
        
        $(window).bind("mouseup", function() {
          
          BookingCalendar.stopDragging();
          
          $(window).unbind("mouseup");
          $("html, body").css("cursor", "auto");
        });
      });
    }
    
    this.posRightTail = function() {
      $("#calendar-tail-right").position({
          "my": "left center",
          "at": "right center",
          "of": $("#fullcalendar .end-date")
      }).show();
    }
    
    this.startDraggingFor = function(element) {
      
      this.dragging = true;
      this.dragging_target = element;
    }
    
    this.stopDragging = function() {
      
      this.dragging = false;
      delete this.dragging_target; 
    }
    
    this.getElementByDate = function(date) {
      var view = BookingCalendar.calendar.fullCalendar("getView");
      var cell = view.dateCell(date);
      var row = $("#fullcalendar .fc-view > table > tbody > tr")[cell.row];
      var element = $(row).find("td")[cell.col];
      return element;
    }
    
    this.getDateByElement = function(element) {
      var view = BookingCalendar.calendar.fullCalendar("getView");
      var col = $(element).index();
      var row = $(element).parent().index();
      var date = view.cellDate({col: col, row: row});
      return date;
    }
    
    this.setupSelection = function() {
      
      BookingCalendar.start_date = new Date($("#book #start_date").val());
      BookingCalendar.end_date = new Date($("#book #end_date").val());
    }
    
    this.setupLocal = function() {
      this.local = i18n.selected.bookingcalendar;
    }
    
    this.setupDateRange = function() {
      
      // first save valid date to data attribute for fallback reason
      
      $("#book .date input").each(function(){
        if(BookingCalendar.validateDate($(this).val())) {
          var date = getDateFromFormat($(this).val(), BookingCalendar.local.dateFormat);
          $(this).data("date", new Date(date));
        }
      });
      
      // keyup binding the date input fields
      
      $("#book .date input").keyup(function(event) {
        
        if(event.keyCode == 38) {
          if(BookingCalendar.validateDate($(this).val())) {
            BookingCalendar.increaseDate(this);
          } else {
            $(this).val(formatDate($(this).data("date"), BookingCalendar.local.dateFormat));
          }
        }
        
        if(event.keyCode == 40) {
          if(BookingCalendar.validateDate($(this).val())) {
            BookingCalendar.decreaseDate(this);
          } else {
            $(this).val(formatDate($(this).data("date"), BookingCalendar.local.dateFormat));
          }
        }
      });
    }
    
    this.increaseDate = function(element) {
      var date = getDateFromFormat($(element).val(), BookingCalendar.local.dateFormat);
      date += BookingCalendar.oneDay; // which is one day in getTime()
      date = new Date(date);
      date = formatDate(date, BookingCalendar.local.dateFormat);
      
      $(element).val(date);
    }
    
    this.decreaseDate = function(element) {
      var date = getDateFromFormat($(element).val(), BookingCalendar.local.dateFormat);
      date -= BookingCalendar.oneDay;
      date = new Date(date);
      date = formatDate(date, BookingCalendar.local.dateFormat);
      
      $(element).val(date);
    }
    
    this.setupStartDate = function() {
      
      // KEYUP & CHANGE
      
      $("#book .date #start_date").bind("keyup change", function() {
        
        var value = $(this).val();
        
        if(BookingCalendar.validateDate(value)) {
          
          var date = new Date(getDateFromFormat(value, BookingCalendar.local.dateFormat));
          var start_date = getDateFromFormat($("#book .date #start_date").val(), BookingCalendar.local.dateFormat);
          var end_date = getDateFromFormat($("#book .date #end_date").val(), BookingCalendar.local.dateFormat);
          var current_date = BookingCalendar.flattenDate(new Date());
          var fullCalendar_date = BookingCalendar.calendar.fullCalendar("getDate");
          
          // set start date one day before end date when dragging if startdate is >= end date 
          if(start_date >= end_date && BookingCalendar.dragging) {
            var new_date = new Date(end_date).getTime() - BookingCalendar.oneDay;
            $(this).val(formatDate(new Date(new_date), BookingCalendar.local.dateFormat));
          }   
          
          // check if the full calendar view shows the same month and year that is setted in the start_date
          
          if(date.getMonth() != fullCalendar_date.getMonth() || date.getFullYear() != fullCalendar_date.getFullYear()) {
            if(BookingCalendar.dragging) {
              
            } else {
              BookingCalendar.gotoDate(date);
            }
          }
          
          // set the new end_date depending of the new start_date
          
          if(start_date >= end_date && !BookingCalendar.dragging) {
            end_date = start_date + BookingCalendar.oneDay;
            end_date = new Date(end_date);
            end_date = formatDate(end_date, BookingCalendar.local.dateFormat);
            $("#book .date #end_date").val(end_date);
            $("#book .date #end_date").change();
          }
          
          // prevent start_date for getting setted to an history value
          
          if(start_date < current_date) {
            $(this).val(formatDate(current_date, BookingCalendar.local.dateFormat));
          }
          
          // save valid date to data attribute for fallback reason and set the new start_date
        
          if(BookingCalendar.validateDate($(this).val())) {
            var date = BookingCalendar.flattenDate(new Date(getDateFromFormat($(this).val(), BookingCalendar.local.dateFormat)));
            $(this).data("date", date);
            BookingCalendar.start_date = date;
            sessionStorage.start_date = JSON.stringify(formatDate(BookingCalendar.start_date, "yyyy-MM-dd"));
            BookingCalendar.setAvDates(true);
          }
          
          // on selecting closed day as start_date
          
          if(BookingCalendar.isClosedDay(date)) {
            BookingCalendar.addClosedDayAlert(date);
          } else {
            BookingCalendar.destroyAllClosedDayAlerts();
          }
        }
      });
      
      // FOCUS
      
      $("#book .date #start_date").bind("focus", function() {
        
        if(BookingCalendar.validateDate(value)) {
          var date = new Date(getDateFromFormat(value, BookingCalendar.local.dateFormat));
          var current_date = BookingCalendar.flattenDate(new Date());
          var fullCalendar_date = BookingCalendar.calendar.fullCalendar("getDate");
          
          // check if the full calendar view shows the same month and year that is setted in the start_date
        
          if(date.getMonth() != fullCalendar_date.getMonth() || date.getFullYear() != fullCalendar_date.getFullYear()) {
            BookingCalendar.gotoDate(date);
          }
        }
        
        // reset closed day alerts on focus
        
        BookingCalendar.destroyAllClosedDayAlerts();
        $(this).change();
      });
    }
    
    this.setupEndDate = function() {
      
      // KEYUP & CHANGE
      
      $("#book .date #end_date").bind("keyup change", function() {
        
        var value = $(this).val();
        
        if(BookingCalendar.validateDate(value)) {
          
          var date = new Date(getDateFromFormat(value, BookingCalendar.local.dateFormat));
          var start_date = getDateFromFormat($("#book .date #start_date").val(), BookingCalendar.local.dateFormat);
          var end_date = getDateFromFormat($("#book .date #end_date").val(), BookingCalendar.local.dateFormat);
          var current_date = BookingCalendar.flattenDate(new Date());
          var fullCalendar_date = BookingCalendar.calendar.fullCalendar("getDate");
          
          // set end date one day after start date when endate is <= start date 
          
          if(end_date <= start_date) {
            var new_date = new Date(start_date).getTime() + BookingCalendar.oneDay;
            $(this).val(formatDate(new Date(new_date), BookingCalendar.local.dateFormat));
          }   
          
          // check if the full calendar view shows the same month and year that is setted
          
          if(date.getMonth() != fullCalendar_date.getMonth() || date.getFullYear() != fullCalendar_date.getFullYear()) {
            if(BookingCalendar.dragging) {
              
            } else {
              BookingCalendar.gotoDate(date);             
            }
          }
          
          // save valid date to data attribute for fallback reason
        
          if(BookingCalendar.validateDate($(this).val())) {
            var date = BookingCalendar.flattenDate(new Date(getDateFromFormat($(this).val(), BookingCalendar.local.dateFormat)));
            $(this).data("date", date);
            BookingCalendar.end_date = date;
            sessionStorage.end_date = JSON.stringify(formatDate(BookingCalendar.end_date, "yyyy-MM-dd"));
            BookingCalendar.setAvDates(true);
          }
          
          // on selecting closed day as end_date
          
          if(BookingCalendar.isClosedDay(date)) {
            BookingCalendar.addClosedDayAlert(date);
          } else {
            BookingCalendar.destroyAllClosedDayAlerts();
          }
        }
      });
      
      // FOCUS
      
      $("#book .date #end_date").bind("focus", function() {
        
        var value = $(this).val();
        
        if(BookingCalendar.validateDate(value)) {
          var date = new Date(getDateFromFormat(value, BookingCalendar.local.dateFormat));
          var current_date = BookingCalendar.flattenDate(new Date());
          var fullCalendar_date = BookingCalendar.calendar.fullCalendar("getDate");
          
          // check if the full calendar view shows the same month and year that is setted
        
          if(date.getMonth() != fullCalendar_date.getMonth() || date.getFullYear() != fullCalendar_date.getFullYear()) {
            BookingCalendar.gotoDate(date);
          }
        }
        
        // reset closed day alerts on focus
        
        BookingCalendar.destroyAllClosedDayAlerts();
        $(this).change();
      });
    }
    
    this.gotoDate = function(date) {
      BookingCalendar.calendar.fullCalendar("gotoDate", date);     
      $(".calendar-tail").hide();  
    }
    
    this.isClosedDay = function(date) {
      return ($("#book #inventory_pool_id option:selected").data("closed_days").indexOf(date.getDay()) !== -1);
    }
    
    this.moveForwardUntilOpend = function(element) {
      
      var count = 0;
      
      if(this.isClosedDay($(element).data("date"))) {
        
        while(this.isClosedDay($(element).data("date")) && count < 7) {
          
         BookingCalendar.increaseDate(element);
         $(element).change();
         count++;
        }
      }
    }
    
    this.destroyAllClosedDayAlerts = function() {
      $(".closed-day-alert").each(function(){
        $(this).removeClass("closed-day-alert");
        $(this).qtip().destroy();
      });
    }
    
    this.addClosedDayAlert = function(date) {
      
      // destroy all closed-day-alerts first
      
      this.destroyAllClosedDayAlerts();
      
      // create qtip
      
      $(BookingCalendar.getElementByDate(date)).qtip({
        content: {
           text: BookingCalendar.local.closedDayAlert.text,
           title: {
              text: BookingCalendar.local.closedDayAlert.title
           }
        },
        position: {
           my: 'bottom center',
           at: 'top center',
           viewport: $(window) // ...and make sure it stays on-screen if possible
        },
        show: {
           event: false, // Only show when show() is called manually
           ready: true // Also show on page load
        },
        hide: false // Don't' hide unless we call hide()
      }).addClass("closed-day-alert");
    }
    
    this.localizeDates = function() {
      
      $("#book .date input").each(function(){
        var date = new Date($(this).val());
        date = formatDate(date, BookingCalendar.local.dateFormat);
        $(this).val(date);
      });
    }
    
    this.validateDate = function(value) {
      var _return = false;
      
      var date = getDateFromFormat(value, BookingCalendar.local.dateFormat);
      
      if(date) {
        var date = new Date(date);
        _return = date;
      }
      
      return _return;
    }
    
    this.setupQuantity = function() {
      
      $("#book input#quantity").data("last_value", $("#book input#quantity").val());
      
      $("#book input#quantity").attr("max", $("select#inventory_pool_id option:selected").data("total_borrowable"));
      
      $("#book input#quantity").focus(function(){
        $(this).select();
      });
      
      $("#book input#quantity").blur(function(){
        $(this).val("");
        $(this).val($(this).data("last_value"));
      });
      
      $("#book input#quantity").bind("change keyup", function(event){
        
        if(event.keyCode == 38)
          BookingCalendar.increaseQuantity();
        
        if(event.keyCode == 40)
          BookingCalendar.decreaseQuantity();
        
        if(BookingCalendar.validateQuantity()) {
          BookingCalendar.setAvDates(true);
        }
      });
      
      $("#book .quantity .increase").click(function(){
        BookingCalendar.increaseQuantity();
        if(BookingCalendar.validateQuantity()) {
          BookingCalendar.setAvDates(true);
        }
      });
      
      $("#book .quantity .decrease").click(function(){
        BookingCalendar.decreaseQuantity();
        if(BookingCalendar.validateQuantity()) {
          BookingCalendar.setAvDates(true);
        }
      });
    }
    
    this.setupInventoryPoolSelector = function() {
      
      $("select#inventory_pool_id").css("max-width", $("select#inventory_pool_id").outerWidth());
      
      $("select#inventory_pool_id option").each(function(){
        
        var string = $(this).data("name");
        string += $(this).data("address") ? " " + $(this).data("address") : "";
        string += $(this).data("total_borrowable") ? " (max. " + $(this).data("total_borrowable") + ")" : "";
        $(this).html(string);
      });
      
      $("select#inventory_pool_id").change(function(){
        
        $("#book input#quantity").attr("max", $("select#inventory_pool_id option:selected").data("total_borrowable"));
        BookingCalendar.setAvDates(true);
        $("#book .inventorypool .select .name").html($("#book .inventorypool option:selected").data("name"));
      });
    }

    this.setupFullcalendar = function() {
      
      BookingCalendar.calendar = $('#fullcalendar').fullCalendar({
        
          viewDisplay: BookingCalendar.viewDisplayFunction,
      
          header: {
              left: 'title',
              right: 'today prev next'
          },
          
          firstDay: BookingCalendar.local.firstDay,
          buttonText: BookingCalendar.local.buttonText,
          monthNames: BookingCalendar.local.monthNames,
          monthNamesShort: BookingCalendar.local.monthNamesShort,
          dayNames: BookingCalendar.local.dayNames,
          dayNamesShort: BookingCalendar.local.dayNamesShort
      });
    }
    
    this.disableTextSelection = function() {
      $("#fullcalendar").disableSelection();
      $(".calendar-tail").disableSelection();
    }
    
    this.increaseQuantity = function() {
      $("#book .quantity input").val(parseInt($("#book .quantity input").val())+1);
    }
    
    this.decreaseQuantity = function() {
      $("#book .quantity input").val(parseInt($("#book .quantity input").val())-1);
    }
    
    this.validateQuantity = function() {
      var _return = true
      
      if(isNaN($("#book input#quantity").val()) || parseInt($("#book input#quantity").val()) > $("#book input#quantity").attr("max") || parseInt($("#book input#quantity").val()) < $("#book input#quantity").attr("min")) {
        $("#book input#quantity").val($("#book input#quantity").data("last_value"));
        $("#book .quantity input").select();
        _return = false;
      }
      
      if (_return)
        $("#book input#quantity").data("last_value", $("#book input#quantity").val());
        
      return _return;
    }
    
    this.viewDisplayFunction = function(view) {
      var availability_dates = $('#fullcalendar').data('availability_dates');
      if (!availability_dates) return false;
      
      var colCnt = $(".fc-week1 .fc-widget-content").length;
      var required_quantity = $('#fullcalendar').data("required_quantity");
      
      // go trough all visible dates (days)
      
      $("#fullcalendar .fc-content .fc-widget-content").each(function(index, element){
        
        var cell = {row: Math.floor(index/colCnt), col: index%colCnt};
        var date = view.cellDate(cell);
        
        var f1 = availability_dates.filter(function(x){
          var availability_date = new Date(x[0] * 1000);
          return (availability_date < date); // TODO <= ???
        });
        
        // add unavailable or available to the element and setting quantity as text depending on availability
        
        var available_quantity = (f1.length ? f1[f1.length-1][1] : 0);
        var class_names = available_quantity >= required_quantity ? ["available", "unavailable"] : ["unavailable", "available"];
        var text = BookingCalendar.isClosedDay(date) ? "" : available_quantity;
        if( BookingCalendar.flattenDate(date) >= BookingCalendar.flattenDate(new Date()) ) {
          $(element).removeClass(class_names[1]).addClass(class_names[0]).find('div.fc-day-content > div').text(text);
        } else {
          $(element).removeClass("available unavailable").find('div.fc-day-content > div').text("");
        }
        
        // add unavailable or available to the element and setting quantity as text depending on closed days of the selected ip
        
        var isClosedDay = BookingCalendar.isClosedDay(date);
        var isStartDate = (BookingCalendar.flattenDate(date).getTime() == BookingCalendar.flattenDate($("#book .date #start_date").data("date")).getTime()) ? true : false;
        var isEndDate = (BookingCalendar.flattenDate(date).getTime() == BookingCalendar.flattenDate($("#book .date #end_date").data("date")).getTime()) ? true : false;
        
        if( isClosedDay && (isStartDate || isEndDate) ) {
          $(element).removeClass("available").addClass("unavailable");
        } else {
          $(element).removeClass(class_names[1]).addClass(class_names[0]);
        }
        
        // add Tail when day is start or end date//note reconsider because its bad to append them directly inside the day cells
        
        if(isStartDate) {
          $(element).addClass("start-date");
          BookingCalendar.posLeftTail();
        } else {
          $(element).removeClass("start-date"); 
        }
        
        if(isEndDate) {
           $(element).addClass("end-date");
           BookingCalendar.posRightTail();
        } else {
          $(element).removeClass("end-date"); 
        }
        
        // add selected or unseleceted to the element
        
        if( BookingCalendar.flattenDate(date) >= BookingCalendar.flattenDate(BookingCalendar.start_date) && BookingCalendar.flattenDate(date) <= BookingCalendar.flattenDate(BookingCalendar.end_date) ) {
          $(element).addClass("selected");
        } else {
          $(element).removeClass("selected");
        }
      });
      
      // disable "go back in months" button to prevent showing the history
      
      if( BookingCalendar.calendar.fullCalendar("getDate") <= new Date() ) {
        $("#fullcalendar .fc-button-prev").addClass("fc-state-disabled");
      } else {
        $("#fullcalendar .fc-button-prev").removeClass("fc-state-disabled");
      }
    }
    
    this.setAvDates = function(render) {
    	var q = parseInt($("#book input#quantity").val());
    	var av = $("select#inventory_pool_id option:selected").data("availability_dates");
    	$('#fullcalendar').data("required_quantity", q).data("availability_dates", av);
    	if (render) $('#fullcalendar').fullCalendar('render');
    }
    
    this.flattenDate = function(date) {
      date.setHours(0);
      date.setMinutes(0);
      date.setSeconds(0);
      date.setMilliseconds(0);
      return date;
    }
}