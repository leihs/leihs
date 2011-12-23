/*
 * Booking-Calendar
 *
 * This script setups the jquery FullCalendar plugin and adds
 * additional features for booking/renting processes
 *
 * @name Booking-Calendar
*/

var BookingCalendar = new BookingCalendar();

function BookingCalendar() {
    this.instance // the current instance of the fullcalendar
    this.oneDay = 86404000; // in milliseconds
    this.local;
    this.start_date = new Date();
    this.end_date = new Date(this.start_date.getTime() + this.oneDay);
    this.click_target;
    this.click_target_clear_timeout;
    this.sessionStorage = false;
    
    
    this.setup = function() {
      if(BookingCalendar.instance != undefined) {
        console.log("BOOKING CALENDAR ALREADY INITALIZED");
      }
      
      if(BookingCalendar.sessionStorage) this.setupFromStorage();
      this.setupSelection();
      this.setupLocal();
      this.setupFullcalendar();
      this.setupQuantity();
      this.setupLines();
      this.localizeDates();
      this.setupDateRange();
      this.setupStartDate();
      this.setupEndDate();
      this.setupJumptoDate();
      this.setupInventoryPoolSelector();
      this.setupGroupSelector();
    	this.setAvDates(true);
    	this.setupView();
    	this.setupDayCells();
    }
    
    this.setupFromStorage = function() {
      if(sessionStorage.start_date && sessionStorage.end_date) {
        $("#start_date").val(JSON.parse(sessionStorage.start_date));
        $("#end_date").val(JSON.parse(sessionStorage.end_date));
      }
    }
    
    this.setupDayCells = function() {
      // setup clicking on day cells
      BookingCalendar.instance.find(".fc-widget-content").live("click", function(event) {
        var date = BookingCalendar.getDateByElement(this);
                
        // break if a day in history was clicked
        if(date.getTime() < BookingCalendar.flattenDate(new Date()).getTime()-3000) return false;
        
        // go on depending if click target is defined  
        if(BookingCalendar.click_target != undefined) {
          // select when click target is available
          $(BookingCalendar.click_target).val(formatDate(date, BookingCalendar.local.dateFormat));
          $("#start_date").change();
          $("#end_date").change();
          $(BookingCalendar.click_target).focus();
        } else {
          // select when clicking outside selection
          if (date.getTime() < BookingCalendar.start_date.getTime()) {
            $("#start_date").val(formatDate(date, BookingCalendar.local.dateFormat)).change();
          } else if (date.getTime() > BookingCalendar.end_date.getTime()) {
            $("#end_date").val(formatDate(date, BookingCalendar.local.dateFormat)).change();
          } else { // click inside selection
            // set values            
            var distance = BookingCalendar.end_date.getTime() - BookingCalendar.start_date.getTime();
            var median = BookingCalendar.start_date.getTime() + distance/2;
            if(date.getTime() < median) {
              $("#start_date").val(formatDate(date, BookingCalendar.local.dateFormat)).change();
            } else {
              $("#end_date").val(formatDate(date, BookingCalendar.local.dateFormat)).change();
            }                   
          }
        }
        
        // change view if user clicked on next or prev month's day
        var fullCalendar_date = BookingCalendar.instance.fullCalendar("getDate");
        if(date.getMonth() != fullCalendar_date.getMonth() || date.getFullYear() != fullCalendar_date.getFullYear()) {
          BookingCalendar.gotoDate(date);
        }
      });
    }
    
    this.getElementByDate = function(date) {
      var view = BookingCalendar.instance.fullCalendar("getView");
      var cell = view.dateCell(date);
      var row = $("#fullcalendar .fc-view > table > tbody > tr")[cell.row];
      var element = $(row).find("td")[cell.col];
      return element;
    }
    
    this.getDateByElement = function(element) {
      var view = BookingCalendar.instance.fullCalendar("getView");
      var col = $(element).index();
      var row = $(element).parent().index();
      var date = view.cellDate({col: col, row: row});
      return date;
    }
    
    this.setupSelection = function() {
      BookingCalendar.start_date = new Date($("#start_date").val().replace(/-/g, "/")); // SAFARI Workarround for Date.parse problem
      BookingCalendar.end_date = new Date($("#end_date").val().replace(/-/g, "/")); // SAFARI Workarround for Date.parse problem
    }
    
    this.setupLocal = function() {
      this.local = i18n.selected.bookingcalendar;
    }
    
    this.setupDateRange = function() {
      // first save valid date to data attribute for fallback reason
      $("#start_date, #end_date").each(function(){
        if(BookingCalendar.validateDate($(this).val())) {
          var date = getDateFromFormat($(this).val(), BookingCalendar.local.dateFormat);
          $(this).data("date", new Date(date));
        }
      });
      
      // keyup binding the date input fields
      $("#start_date, #end_date").keyup(function(event) {
        
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
      
      $("#start_date").bind("keyup change", function(event) {
        var value = $(this).val();
        if(BookingCalendar.validateDate(value)) {
          var date = new Date(getDateFromFormat(value, BookingCalendar.local.dateFormat));
          var start_date = getDateFromFormat($("#start_date").val(), BookingCalendar.local.dateFormat);
          var end_date = getDateFromFormat($("#end_date").val(), BookingCalendar.local.dateFormat);
          var current_date = BookingCalendar.flattenDate(new Date());
          var fullCalendar_date = BookingCalendar.instance.fullCalendar("getDate");
          
          // set the new end_date depending of the new start_date
          if(start_date > end_date && !BookingCalendar.click_target.is("#end_date")) {
            $("#end_date").val(formatDate(new Date(start_date), BookingCalendar.local.dateFormat)).change();
          }
          
          // prevent start_date for getting setted to an history value
          if(start_date < current_date) {
            $(this).val(formatDate(current_date, BookingCalendar.local.dateFormat));
          }
          
          // on change change viewport
          if(BookingCalendar.validateDate($(this).val()) && event.type == "keyup") {
            // check if the full calendar view shows the same month and year that is setted
            if(date.getMonth() != fullCalendar_date.getMonth() || date.getFullYear() != fullCalendar_date.getFullYear()) {
              BookingCalendar.gotoDate(date);
            }
          }
          
          // save valid date to data attribute for fallback reason and set the new start_date
          if(BookingCalendar.validateDate($(this).val())) {
            var date = BookingCalendar.flattenDate(new Date(getDateFromFormat($(this).val(), BookingCalendar.local.dateFormat)));
            $(this).data("date", date);
            BookingCalendar.start_date = date;
            if(BookingCalendar.sessionStorage) sessionStorage.start_date = JSON.stringify(formatDate(BookingCalendar.start_date, "yyyy-MM-dd"));
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
      $("#start_date").bind("focus", function() {
        var value = $(this).val();
        
        if(BookingCalendar.validateDate(value)) {
          var date = new Date(getDateFromFormat(value, BookingCalendar.local.dateFormat));
          var current_date = BookingCalendar.flattenDate(new Date());
          var fullCalendar_date = BookingCalendar.instance.fullCalendar("getDate");
        }
        
        // reset closed day alerts on focus
        BookingCalendar.destroyAllClosedDayAlerts();
        
        // set click target
        BookingCalendar.click_target = $(this);
        
        // clear click target clear timeout
        window.clearTimeout(BookingCalendar.click_target_clear_timeout);
      });
      
      // BLUR
      $("#start_date").bind("blur", function() {
        BookingCalendar.click_target_clear_timeout = window.setTimeout(function(){
          BookingCalendar.click_target = undefined;
        }, 100);
      });
    }
    
    this.setupEndDate = function() {
      
      // KEYUP & CHANGE
      $("#end_date").bind("keyup change", function(event) {
        var value = $(this).val();
        
        if(BookingCalendar.validateDate(value)) {
          var date = new Date(getDateFromFormat(value, BookingCalendar.local.dateFormat));
          var start_date = getDateFromFormat($("#start_date").val(), BookingCalendar.local.dateFormat);
          var end_date = getDateFromFormat($("#end_date").val(), BookingCalendar.local.dateFormat);
          var current_date = BookingCalendar.flattenDate(new Date());
          var fullCalendar_date = BookingCalendar.instance.fullCalendar("getDate");
          
          // set start date to end date when endate is <= start date
          if(end_date < start_date) {
            $("#start_date").val(formatDate(new Date(end_date), BookingCalendar.local.dateFormat)).change();
          }   
          
          // on change change viewport
          if(BookingCalendar.validateDate($(this).val()) && event.type == "keyup") {
            // check if the full calendar view shows the same month and year that is setted
            if(date.getMonth() != fullCalendar_date.getMonth() || date.getFullYear() != fullCalendar_date.getFullYear()) {
              BookingCalendar.gotoDate(date);
            }
          }
          
          // save valid date to data attribute for fallback reason
          if(BookingCalendar.validateDate($(this).val())) {
            var date = BookingCalendar.flattenDate(new Date(getDateFromFormat($(this).val(), BookingCalendar.local.dateFormat)));
            $(this).data("date", date);
            BookingCalendar.end_date = date;
            if(BookingCalendar.sessionStorage) sessionStorage.end_date = JSON.stringify(formatDate(BookingCalendar.end_date, "yyyy-MM-dd"));
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
      $("#end_date").bind("focus", function() {
        var value = $(this).val();
        
        if(BookingCalendar.validateDate(value)) {
          var date = new Date(getDateFromFormat(value, BookingCalendar.local.dateFormat));
          var current_date = BookingCalendar.flattenDate(new Date());
          var fullCalendar_date = BookingCalendar.instance.fullCalendar("getDate");
        }
        
        // reset closed day alerts on focus
        BookingCalendar.destroyAllClosedDayAlerts();
        
        // set click target
        BookingCalendar.click_target = $(this);
        
        // clear click target clear timeout
        window.clearTimeout(BookingCalendar.click_target_clear_timeout);
      });
      
      // BLUR
      $("#end_date").bind("blur", function() {
        BookingCalendar.click_target_clear_timeout = window.setTimeout(function(){
          BookingCalendar.click_target = undefined;
        }, 100);
      });
    }
    
    this.setupJumptoDate = function() {
      $(".fc-goto-start").click(function(){
        BookingCalendar.gotoDate(new Date(getDateFromFormat($("#start_date").val(), BookingCalendar.local.dateFormat)));
      });
      
      $(".fc-goto-end").click(function(){
        BookingCalendar.gotoDate(new Date(getDateFromFormat($("#end_date").val(), BookingCalendar.local.dateFormat)));
      });
    }
    
    this.gotoDate = function(date) {
      BookingCalendar.instance.fullCalendar("gotoDate", date);     
    }
    
    this.isClosedDay = function(date) {
      return ($("#inventory_pool_id option:selected").data("closed_days").indexOf(date.getDay()) !== -1);
    }
    
    this.destroyAllClosedDayAlerts = function() {
      $(".closed-day-alert").each(function(){
        $(this).removeClass("closed-day-alert");
        $(this).remove();
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
        style: {
          classes: "closed-day-alert"
        },
        hide: false // Don't' hide unless we call hide()
      });
    }
    
    this.localizeDates = function() {
      
      $("#start_date, #end_date").each(function(){
        var date = new Date($(this).val().replace(/-/g,"/"));
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
      $("input#quantity").data("last_value", $("input#quantity").val());
      if($("input#quantity").data("check_max") != false) {
        $("input#quantity").attr("max", $("select#inventory_pool_id option:selected").data("total_borrowable"));
      }
      $("input#quantity").focus(function(){
        $(this).select();
      });
      
      $("input#quantity").blur(function(){
        $(this).val("");
        $(this).val($(this).data("last_value"));
      });
      
      $("input#quantity").bind("change keyup", function(event){
        if(event.keyCode == 38)
          BookingCalendar.increaseQuantity();
        if(event.keyCode == 40)
          BookingCalendar.decreaseQuantity();
        if(BookingCalendar.validateQuantity()) {
          BookingCalendar.setAvDates(true);
        }
      });
      
      $(".quantity .increase").click(function(){
        BookingCalendar.increaseQuantity();
        if(BookingCalendar.validateQuantity()) {
          BookingCalendar.setAvDates(true);
        }
      });
      
      $(".quantity .decrease").click(function(){
        BookingCalendar.decreaseQuantity();
        if(BookingCalendar.validateQuantity()) {
          BookingCalendar.setAvDates(true);
        }
      });
    }
    
    
    this.setupLines = function() {
      var line_ids = BookingCalendar.instance.data("line_ids");
      if(line_ids) {
        var form = $(BookingCalendar.instance).closest("form");
        var form_action = $(form).attr("action");
        var lines_params = "";
        
        // iterate and apend lines
        $.each(line_ids, function(index,line){
          if(lines_params == "") {
            lines_params = "line_ids[]=" + line_ids;      
          } else {
            lines_params = lines_params + "&line_ids[]=" + line_ids;
          }
        });
        
        // apend get params to action
        if(form_action.search(/\?/) == -1) form_action = form_action+"?";
        form_action = form_action+lines_params;
        $(form).attr("action", form_action);   
      }
    }
    
    this.setupView = function() {
      var date = new Date(getDateFromFormat($("#start_date").val(), BookingCalendar.local.dateFormat));
      var fullCalendar_date = BookingCalendar.instance.fullCalendar("getDate");
      // check if the full calendar view shows the same month and year that is setted in the start_date
      if(date.getMonth() != fullCalendar_date.getMonth() || date.getFullYear() != fullCalendar_date.getFullYear()) {
        BookingCalendar.gotoDate(date);
      }
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
        $("input#quantity").attr("max", $("select#inventory_pool_id option:selected").data("total_borrowable"));
        BookingCalendar.setAvDates(true);
        $(".inventorypool .select .name").html($(".inventorypool option:selected").data("name"));
      });
    }
    
    this.setupGroupSelector = function() {
      if("select#group".length == 0) return false;
      
      $("select#group").css("max-width", $("select#group").outerWidth());
      
      $("select#group").change(function(){
        $(this).parent(".select").find(".name").html($("select#group option:selected").data("name"));
        
        // set selected_group_id
        if($(this).val().length == 0) {
          BookingCalendar.instance.removeData("selected_group_id");
        } else {
          BookingCalendar.instance.data("selected_group_id", $(this).val());
        }
        
        // render the changed av dates in the fullcalnder
        BookingCalendar.setAvDates(true);
      });
    }

    this.setupFullcalendar = function() {
      BookingCalendar.instance = $('#fullcalendar').fullCalendar({
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
    
    this.increaseQuantity = function() {
      $(".quantity input").val(parseInt($(".quantity input").val())+1);
    }
    
    this.decreaseQuantity = function() {
      $(".quantity input").val(parseInt($(".quantity input").val())-1);
    }
    
    this.validateQuantity = function() {
      var _return = true
      
      if(isNaN($("input#quantity").val()) || parseInt($("input#quantity").val()) > $("input#quantity").attr("max") || parseInt($("input#quantity").val()) < $("input#quantity").attr("min")) {
        $("input#quantity").val($("input#quantity").data("last_value"));
        $(".quantity input").select();
        _return = false;
      }
      
      if (_return)
        $("input#quantity").data("last_value", $("input#quantity").val());
        
      return _return;
    }
    
    this.viewDisplayFunction = function(view) {
      console.log("VIEW DISPLAY FUNCTION");
      var availability_dates = $('#fullcalendar').data('availability_dates');
      if (!availability_dates) return false;
      
      var colCnt = $(".fc-week1 .fc-widget-content").length;
      var required_quantity = $('#fullcalendar').data("required_quantity");
      
      // go trough all visible dates (days)
      $("#fullcalendar .fc-content .fc-widget-content").each(function(index, element){
        
        var cell = {row: Math.floor(index/colCnt), col: index%colCnt};
        var date = view.cellDate(cell);
        
        // get all past (and today) availability dates
        var past_availabilities = availability_dates.filter(function(x){
          var availability_date = new Date(x[0].replace(/-/g, "/"));
          availability_date = BookingCalendar.flattenDate(availability_date);
          return (availability_date <= date);
        });
        
        // we just need the most recent past_av_date
        var most_recent_av = (past_availabilities.length ? past_availabilities[past_availabilities.length-1] : [0,0]);
        
        // selected available_quantity depending on selected group
        var total_quantity = most_recent_av[1]; 
        var available_quantity = total_quantity;
        if(BookingCalendar.instance.data("selected_group_id") != undefined) {
          for (var i in most_recent_av[2]) {
            if(BookingCalendar.instance.data("selected_group_id") == most_recent_av[2][i].group_id) {
              available_quantity = most_recent_av[2][i].in_quantity;
            }
          }
        }
        
        // add unavailable or available to the element and setting quantity as text depending on availability
        var class_names = available_quantity >= required_quantity ? ["available", "unavailable"] : ["unavailable", "available"];
        if( BookingCalendar.flattenDate(date) >= BookingCalendar.flattenDate(new Date()) && !BookingCalendar.isClosedDay(date)) {
          $(element).removeClass(class_names[1]).addClass(class_names[0]).find('div.fc-day-content > div').text(available_quantity);
          $(element).removeClass("available unavailable").find('div.fc-day-content .total_quantity').remove();
          if(BookingCalendar.instance.data("selected_group_id") != undefined) $(element).find('div.fc-day-content').append("<div class='total_quantity'>/"+total_quantity+"</div>");
        } else {
          $(element).removeClass("available unavailable").find('div.fc-day-content > div').text("");
          $(element).removeClass("available unavailable").find('div.fc-day-content .total_quantity').remove();
        }
        
        // add unavailable or available to the element and setting quantity as text depending on closed days of the selected ip
        var isClosedDay = BookingCalendar.isClosedDay(date);
        var isStartDate = (BookingCalendar.flattenDate(date).getTime() == BookingCalendar.flattenDate($(".date #start_date").data("date")).getTime()) ? true : false;
        var isEndDate = (BookingCalendar.flattenDate(date).getTime() == BookingCalendar.flattenDate($(".date #end_date").data("date")).getTime()) ? true : false;
        
        if( isClosedDay && (isStartDate || isEndDate) ) {
          $(element).removeClass("available").addClass("unavailable");
        } else {
          $(element).removeClass(class_names[1]).addClass(class_names[0]);
        }
        
        // add Tail when day is start date //note reconsider because its bad to append them directly inside the day cells
        if(isStartDate) {
          $(element).addClass("start-date");
          $("#calendar-tail-left").remove();
          $(element).children("div").append("<div id='calendar-tail-left' class='calendar-tail'></div>");
          $("#calendar-tail-left").show();
        } else {
          $(element).removeClass("start-date");
        }
        if($("#fullcalendar .fc-widget-content.start-date").length == 0) $("#calendar-tail-left").remove();
        
        // add Tail when day is end date 
        if(isEndDate) {
           $(element).addClass("end-date");
           $("#calendar-tail-right").remove();
           $(element).children("div").append("<div id='calendar-tail-right' class='calendar-tail'></div>");
           $("#calendar-tail-right").show();
        } else {
          $(element).removeClass("end-date");
        }
        if($("#fullcalendar .fc-widget-content.end-date").length == 0) $("#calendar-tail-right").remove();
        
        // add selected or unseleceted to the element
        if( BookingCalendar.flattenDate(date) >= BookingCalendar.flattenDate(BookingCalendar.start_date) && BookingCalendar.flattenDate(date) <= BookingCalendar.flattenDate(BookingCalendar.end_date) ) {
          $(element).addClass("selected");
        } else {
          $(element).removeClass("selected");
        }
      });
      
      // disable "go back in months" button to prevent showing the history
      if( BookingCalendar.instance.fullCalendar("getDate") <= new Date() ) {
        $("#fullcalendar .fc-button-prev").addClass("fc-state-disabled");
      } else {
        $("#fullcalendar .fc-button-prev").removeClass("fc-state-disabled");
      }
    }
    
    this.setAvDates = function(render) {
    	var q = parseInt($("input#quantity").val());
    	var av = $("select#inventory_pool_id option:selected").data("availability_dates");
    	$('#fullcalendar').data("required_quantity", q).data("availability_dates", av);
    	if (render) {
    	  $('#fullcalendar').fullCalendar('render');
    	}
    }
    
    this.flattenDate = function(date) {
      date.setHours(0);
      date.setMinutes(0);
      date.setSeconds(0);
      date.setMilliseconds(0);
      return date;
    }
}