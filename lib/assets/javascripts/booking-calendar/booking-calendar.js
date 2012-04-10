/*
 * Booking-Calendar
 *
 * This script setups the jquery FullCalendar plugin and adds
 * additional features for booking/renting processes
 *
 * @name Booking-Calendar
 * @dependencies: jQuery, moment.js, fullcalendar
*/

var BookingCalendar = new BookingCalendar();

function BookingCalendar() {
  this.instance // the current instance of the fullcalendar
  this.local;
  this.start_date = moment().sod();
  this.end_date = moment().add("days", 1).sod();
  this.sessionStorage = false;
  
  this.setup = function() {
    if(BookingCalendar.sessionStorage) this.setupFromStorage();
    this.setupDateSelection();
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
    this.setupPartitionSelector();
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
    BookingCalendar.instance.find(".fc-widget-content").bind("click", function(event) {
      var date = BookingCalendar.getDateByElement(this);
      
      // break if a day in history was clicked
      if(date.getTime() < moment().sod().toDate().getTime()){
        $(".qtip.target-selection").qtip("hide");  
        $(".selected_for_target_selection").removeClass("selected_for_target_selection");      
        return false;
      } 
      
      // mark this element has .selected
      $(".selected_for_target_selection").removeClass("selected_for_target_selection");
      $(this).addClass("selected_for_target_selection");
      
      // open qtip with the question if the startdate or the enddate has to be set for this day
      $(this).qtip({
        content: {
           text: $.tmpl("tmpl/dialog/calendar/target_selection"),
        },
        position: {
           my: 'bottom center',
           at: 'top center',
           viewport: $(window) // ...and make sure it stays on-screen if possible
        },
        show: {
           event: false, // Only show when show() is called manually
           ready: true, // Also show on page load
           delay: 0
        },
        style: {
          classes: "target-selection"
        },
        hide: false // Don't' hide unless we call hide()
      });
      
      // stop propagation
      return false;
    });
    
    // setup click on somethin else for closing target-selection
    $(window).bind("click",function(event){
      //var target = event.originalEvent.originalTarget;
      $(".qtip.target-selection").qtip("hide");
      $(".selected_for_target_selection").removeClass("selected_for_target_selection");
    });
    
    // setup click on target selection
    $(".target-selection a").die("click");
    $(".target-selection a").live("click", function(event){
      var target = $(".selected_for_target_selection");
      var date = BookingCalendar.getDateByElement(target);
      if($(this).hasClass("start_date")){
        $("#start_date").val(moment(date).format(BookingCalendar.local.dateFormat)).change();
      } else if ($(this).hasClass("end_date")) {
        $("#end_date").val(moment(date).format(BookingCalendar.local.dateFormat)).change();
      }
      $(".selected_for_target_selection").removeClass("selected_for_target_selection");
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
  
  this.setupDateSelection = function() {
    BookingCalendar.start_date = moment($("#start_date").val()).toDate();
    // move start date to today if its in the past
    if(BookingCalendar.start_date < moment().sod()) {
      BookingCalendar.start_date = moment().sod().toDate();
      $("#start_date").val(BookingCalendar.start_date);
    }
    BookingCalendar.end_date = moment($("#end_date").val()).toDate();
    // move end date to start date if its behind start_date
    if(BookingCalendar.end_date < BookingCalendar.start_date) {
      BookingCalendar.end_date = BookingCalendar.start_date;
      $("#end_date").val(BookingCalendar.end_date);
    }
  }
  
  this.setupLocal = function() {
    this.local = {dateFormat: i18n.date.L,
                  firstDay: i18n.days.first,
                  buttonText: {
                    today: i18n.today,
                    month: i18n.month,
                    week: i18n.week,
                    day: i18n.day},
                  monthNames: i18n.months.full,
                  monthNamesShort: i18n.months.trunc,
                  dayNames: i18n.days.full,
                  dayNamesShort: i18n.days.trunc,
                  closedDayAlert: {
                    title: i18n.regard_opening_hours,
                    text: i18n.closed_at_this_day
                  }};
  }
  
  this.setupDateRange = function() {
    // first save valid date to data attribute for fallback reason
    $("#start_date, #end_date").each(function(){
      if(BookingCalendar.validateDate($(this).val())) {
        var date = moment($(this).val(), BookingCalendar.local.dateFormat);
        $(this).data("date", date);
      }
    });
    
    // keyup binding the date input fields
    $("#start_date, #end_date").keyup(function(event) {
      
      if(event.keyCode == 38) {
        if(BookingCalendar.validateDate($(this).val())) {
          BookingCalendar.increaseDate(this);
        } else {
          $(this).val(moment($(this).data("date")).format(BookingCalendar.local.dateFormat));
        }
      }
      
      if(event.keyCode == 40) {
        if(BookingCalendar.validateDate($(this).val())) {
          BookingCalendar.decreaseDate(this);
        } else {
          $(this).val(moment($(this).data("date")).format(BookingCalendar.local.dateFormat));
        }
      }
    });
  }
  
  this.increaseDate = function(element) {
    var date = moment($(element).val(), BookingCalendar.local.dateFormat).add("days", 1).format(BookingCalendar.local.dateFormat);
    $(element).val(date);
  }
  
  this.decreaseDate = function(element) {
    var date = moment($(element).val(), BookingCalendar.local.dateFormat).subtract("days", 1).format(BookingCalendar.local.dateFormat);
    $(element).val(date);
  }
  
  this.setupStartDate = function() {
    
    $("#start_date").bind("keyup change", function(event) {
      var value = $(this).val();
      if(BookingCalendar.validateDate(value)) {
        var date = moment(value, BookingCalendar.local.dateFormat);
        
        var start_date = moment($("#start_date").val(), BookingCalendar.local.dateFormat).sod();
        var end_date = moment($("#end_date").val(), BookingCalendar.local.dateFormat).sod();
        
        var current_date = moment().sod();
        var fullCalendar_date = moment(BookingCalendar.instance.fullCalendar("getDate"));
        
        // reset all closed day alerts
        BookingCalendar.destroyAllClosedDayAlerts();
        
        // set the new end_date depending of the new start_date
        if(start_date > end_date) {
          $("#end_date").val(moment(start_date).format(BookingCalendar.local.dateFormat)).change();
        }
        
        // prevent start_date for getting setted to an history value
        if(start_date < current_date) {
          $(this).val(moment(current_date).format(BookingCalendar.local.dateFormat));
        }
        
        // on change change viewport
        if(BookingCalendar.validateDate($(this).val()) && event.type == "keyup") {
          // check if the full calendar view shows the same month and year that is setted
          if(date.month() != fullCalendar_date.month() || date.year() != fullCalendar_date.year()) {
            BookingCalendar.gotoDate(date);
          }
        }
        
        // save valid date to data attribute for fallback reason and set the new start_date
        if(BookingCalendar.validateDate($(this).val())) {
          $(this).data("date", date);
          BookingCalendar.start_date = date.toDate();
          if(BookingCalendar.sessionStorage) sessionStorage.start_date = JSON.stringify(moment(date).format("yyyy-MM-dd"));
          BookingCalendar.setAvDates(true);
        }
      }
    });
    
    // FOCUS
    $("#start_date").bind("focus", function() {
      var value = $(this).val();
      if(BookingCalendar.validateDate(value)) {
        var date = moment(value, BookingCalendar.local.dateFormat);
        var current_date = moment().sod();
        var fullCalendar_date = BookingCalendar.instance.fullCalendar("getDate");
      }
    });
  }
  
  this.setupEndDate = function() {
    
    // KEYUP & CHANGE
    $("#end_date").bind("keyup change", function(event) {
      var value = $(this).val();
      
      if(BookingCalendar.validateDate(value)) {
        var date = moment(value, BookingCalendar.local.dateFormat);
        var start_date = moment($("#start_date").val(), BookingCalendar.local.dateFormat);
        var end_date = moment($("#end_date").val(), BookingCalendar.local.dateFormat);
        var current_date = moment().sod();
        var fullCalendar_date = BookingCalendar.instance.fullCalendar("getDate");
        
        // set start date to end date when endate is <= start date
        if(end_date < start_date) {
          $("#start_date").val(moment(end_date).format(BookingCalendar.local.dateFormat)).change();
        }
        
        // reset all closed day alerts
        BookingCalendar.destroyAllClosedDayAlerts();
        
        // on change change viewport
        if(BookingCalendar.validateDate($(this).val()) && event.type == "keyup") {
          // check if the full calendar view shows the same month and year that is setted
          if(date.getMonth() != fullCalendar_date.getMonth() || date.getFullYear() != fullCalendar_date.getFullYear()) {
            BookingCalendar.gotoDate(date);
          }
        }
        
        // save valid date to data attribute for fallback reason
        if(BookingCalendar.validateDate($(this).val())) {
          var date = moment($(this).val(), BookingCalendar.local.dateFormat).sod();
          $(this).data("date", date);
          BookingCalendar.end_date = date.toDate();
          if(BookingCalendar.sessionStorage) sessionStorage.end_date = JSON.stringify(moment(date).format("yyyy-MM-dd"));
          BookingCalendar.setAvDates(true);
        }
      }
    });
    
    // FOCUS
    $("#end_date").bind("focus", function() {
      var value = $(this).val();
      if(BookingCalendar.validateDate(value)) {
        var date = moment(value, BookingCalendar.local.dateFormat);
        var current_date = moment().sod();
        var fullCalendar_date = BookingCalendar.instance.fullCalendar("getDate");
      }
    });
  }
  
  this.setupJumptoDate = function() {
    $(".fc-goto-start").click(function(){
      BookingCalendar.gotoDate(moment($("#start_date").val(), BookingCalendar.local.dateFormat).toDate());
    });
    
    $(".fc-goto-end").click(function(){
      BookingCalendar.gotoDate(moment($("#end_date").val(), BookingCalendar.local.dateFormat).toDate());
    });
  }
  
  this.gotoDate = function(date) {
    BookingCalendar.instance.fullCalendar("gotoDate", date);
  }
  
  this.isClosedDay = function(date) {
    return ($("#inventory_pool_id option:selected").data("closed_days").indexOf(date.getDay()) !== -1);
  }
  
  this.isHoliday = function(date) { // should return the holiday name or false
    result = false;
    $.each($("#inventory_pool_id option:selected").data("holidays"), function(i, holiday){
      if(date >= moment(holiday.start_date) && date <= moment(holiday.end_date)) {
        result = holiday.name;
        return false; // breaks the $.each loop
       } 
    });
    
    return result;
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
         ready: true, // Also show on page load
         delay: 0,
         effect: function(offset) { // hide after x milliseconds
          $(this).show();
          var _this = $(this);
          window.setTimeout(function(){
            $(_this).qtip("hide");
          }, 3000);
         }
      },
      style: {
        classes: "closed-day-alert"
      },
      hide: false // Don't' hide unless we call hide()
    });
  }
  
  this.localizeDates = function() {
    
    $("#start_date, #end_date").each(function(){
      formatted_date = moment($(this).val()).format(BookingCalendar.local.dateFormat);
      $(this).val(formatted_date);
    });
  }
  
  this.validateDate = function(value) {
    return (moment(value, BookingCalendar.local.dateFormat).format(BookingCalendar.local.dateFormat) == value);
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
    var date = moment($("#start_date").val(), BookingCalendar.local.dateFormat);
    var fullCalendar_date = moment(BookingCalendar.instance.fullCalendar("getDate"));
    // check if the full calendar view shows the same month and year that is setted in the start_date
    if(date.month() != fullCalendar_date.month() || date.year() != fullCalendar_date.year()) {
      BookingCalendar.gotoDate(date.toDate());
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
    
    // force to select the first option
    $("select#inventory_pool_id option:first").select();
  }
  
  this.setupPartitionSelector = function() {
    BookingCalendar.setSelectedPartitions($("select#partition option:first").val()); // set on startup
    
    if("select#partition".length == 0) return false;
    
    $("select#partition").css("max-width", $("select#partition").outerWidth());
    
    $("select#partition").change(function(){
      partition_name = $("select#partition option:selected").data("name");
      partition_name = (partition_name.length > 15) ? partition_name.substring(0,14)+"..." : partition_name;
      $(this).parent(".select").find(".name").html(partition_name);
      BookingCalendar.setSelectedPartitions($(this).val());
    });
  }

  this.setSelectedPartitions = function(val) {
    if(val.length == 0) {
      BookingCalendar.instance.removeData("selected_partition_ids");
    } else {
      BookingCalendar.instance.data("selected_partition_ids", JSON.parse(val));
    }
    
    // render the changed av dates in the fullcalnder
    BookingCalendar.setAvDates(true);
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
    var availability_dates = $('#fullcalendar').data('availability_dates');
    if (!availability_dates) return false;
    
    var colCnt = $(".fc-week1 .fc-widget-content").length;
    var required_quantity = $('#fullcalendar').data("required_quantity");
    
    // reset all closed day alerts first
    BookingCalendar.destroyAllClosedDayAlerts();
    
    // go trough all visible dates (days)
    $("#fullcalendar .fc-content .fc-widget-content").each(function(index, element){
      
      var cell = {row: Math.floor(index/colCnt), col: index%colCnt};
      var date = view.cellDate(cell);
      
      // get all past (and today) availability dates
      var past_availabilities = availability_dates.filter(function(x){
        var availability_date = moment(x[0]).sod();
        return (availability_date <= date);
      });
      
      // we just need the most recent past_av_date
      var most_recent_av = (past_availabilities.length ? past_availabilities[past_availabilities.length-1] : [0,0]);
      
      // selected available_quantity depending on selected group
      var total_quantity = most_recent_av[1]; 
      var available_quantity = total_quantity;
      if(BookingCalendar.instance.data("selected_partition_ids") != undefined) {
        available_quantity = 0;
        for (var i in most_recent_av[2]) { // each availability entry
          if(BookingCalendar.instance.data("selected_partition_ids").indexOf(most_recent_av[2][i].group_id) > -1 || most_recent_av[2][i].group_id == null || most_recent_av[2][i].group_id == 0) { // null or 0 is the group "general" (the everyone partition)
            available_quantity+= most_recent_av[2][i].in_quantity;
          }
        }
      }
      
      // add unavailable or available to the element and setting quantity as text depending on availability
      var class_names = available_quantity >= required_quantity ? ["available", "unavailable"] : ["unavailable", "available"];
      var isHoliday = BookingCalendar.isHoliday(date);
      if(moment(date).sod() >= moment().sod() && !BookingCalendar.isClosedDay(date) && !isHoliday) {
        // add class unavailable or available (switch)
        $(element).removeClass(class_names[1]).addClass(class_names[0]);
        // add just a 0 (zero) to unavailable dates if the fullcalendar is in multiple mode
        if($(BookingCalendar.instance).hasClass("multiple")){
          $(element).removeClass(class_names[1]).addClass(class_names[0]);
          if($(element).hasClass("unavailable")) {
            $(element).find('div.fc-day-content > div').text("x");
          } else {
            $(element).find('div.fc-day-content > div').text("✓");
          }
        } else { // 
          $(element).find('div.fc-day-content > div').text(available_quantity);
          $(element).removeClass("available unavailable").find('div.fc-day-content .total_quantity').remove();
          if(BookingCalendar.instance.data("selected_partition_ids") != undefined) $(element).find('div.fc-day-content').append("<span class='total_quantity'>/"+total_quantity+"</span>");
        }
      } else {
        $(element).removeClass("available unavailable").find('div.fc-day-content > div').text("");
        $(element).removeClass("available unavailable").find('div.fc-day-content .total_quantity').remove();
      }
      
      // take care of holidays
      if(isHoliday) {
        if($(element).find('div.fc-day-content .holiday').length == 0) $(element).find('div.fc-day-content').append("<span class='holiday'>"+isHoliday+"</span>");
      } else {
        $(element).find('div.fc-day-content .holiday').remove();
      }
      
      // add unavailable or available to the element and setting quantity as text depending on closed days of the selected ip
      var isClosedDay = BookingCalendar.isClosedDay(date);
      var isStartDate = (moment(date).sod().toDate().getTime() == moment($(".date #start_date").data("date")).sod().toDate().getTime()) ? true : false;
      var isEndDate = (moment(date).sod().toDate().getTime() == moment($(".date #end_date").data("date")).sod().toDate().getTime()) ? true : false;
      
      if( (isClosedDay || isHoliday) && (isStartDate || isEndDate) ) {
        $(element).removeClass("available").addClass("unavailable");
      } else {
        $(element).removeClass(class_names[1]).addClass(class_names[0]);
      }
      
      // check if end date is a closed day
      if((BookingCalendar.isClosedDay(date) || BookingCalendar.isHoliday(date)) && (isStartDate || isEndDate)) {
        BookingCalendar.addClosedDayAlert(date);
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
      if( moment(date).sod() >= moment(BookingCalendar.start_date).sod() && moment(date).sod() <= moment(BookingCalendar.end_date).sod()) {
        $(element).addClass("selected");
      } else {
        $(element).removeClass("selected");
      }
      
      // add history if day is a history day
      if(moment(date).sod() < moment().sod()) {
        $(element).addClass("history");
      } else {
        $(element).removeClass("history");
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
}