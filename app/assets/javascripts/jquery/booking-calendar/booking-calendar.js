$(document).ready(function(){
  
	BookingCalendar.setup();
	
});

var BookingCalendar = new BookingCalendar();

function BookingCalendar() {
  
    this.firstDay   = 1; // for Monday as first day of the week
    
    this.calendar // an instance of the fullcalendar
    
    this.oneDay = 86404000; // in milliseconds
    
    this.local = { // this is default
      dateFormat: "dd.MM.yyyy" //for example: dd.MM.yyyy
    };
    
    this.setup = function() {
      
      this.setupLocal();
      
      this.setupFullcalendar();
      
      this.setupQuantity();
      
      this.localizeDates();
      
      this.setupDateRange();
      
      this.setupStartDate();
      
      this.setupEndDate();
      
      this.setupInventoryPoolSelector();
      
    	this.setData(true);
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
            $(this).val(BookingCalendar.increaseDate(this));
          } else {
            $(this).val(formatDate($(this).data("date"), BookingCalendar.local.dateFormat));
          }
        }
        
        if(event.keyCode == 40) {
          if(BookingCalendar.validateDate($(this).val())) {
            $(this).val(BookingCalendar.decreaseDate(this));
          } else {
            $(this).val(formatDate($(this).data("date"), BookingCalendar.local.dateFormat));
          }
        }
      });
    }
    
    this.increaseDate = function(dateField) {
      var date = getDateFromFormat($(dateField).val(), BookingCalendar.local.dateFormat);
      date += BookingCalendar.oneDay; // which is one day in getTime()
      date = new Date(date);
      date = formatDate(date, BookingCalendar.local.dateFormat);
      
      return date;
    }
    
    this.decreaseDate = function(dateField) {
      var date = getDateFromFormat($(dateField).val(), BookingCalendar.local.dateFormat);
      date -= BookingCalendar.oneDay;
      date = new Date(date);
      date = formatDate(date, BookingCalendar.local.dateFormat);
      
      return date;
    }
    
    this.setupStartDate = function() {
      
      $("#book .date #start_date").bind("keyup", function() {
        
        var value = $(this).val();
        
        if(BookingCalendar.validateDate(value)) {
          
          var date = new Date(getDateFromFormat(value, BookingCalendar.local.dateFormat));
          var start_date = getDateFromFormat($("#book .date #start_date").val(), BookingCalendar.local.dateFormat);
          var end_date = getDateFromFormat($("#book .date #end_date").val(), BookingCalendar.local.dateFormat);
          var current_date = new Date(); current_date.setHours(0); current_date.setMinutes(0); current_date.setSeconds(0); current_date.setMilliseconds(0);
          var fullCalendar_date = BookingCalendar.calendar.fullCalendar("getDate");
          
          // check if the full calendar view shows the same month and year that is setted in the start_date
          
          if(date.getMonth() != fullCalendar_date.getMonth() || date.getFullYear() != fullCalendar_date.getFullYear()) {
            BookingCalendar.calendar.fullCalendar("gotoDate", date);
          }
          
          // set the new end_date depending of the new start_date
          
          if(start_date >= end_date) {
            end_date = start_date + BookingCalendar.oneDay;
            end_date = new Date(end_date);
            end_date = formatDate(end_date, BookingCalendar.local.dateFormat);
            $("#book .date #end_date").val(end_date);
          }
          
          // prevent start_date for getting setted to an history value
          
          if(start_date < current_date) {
            $(this).val(formatDate(current_date, BookingCalendar.local.dateFormat));
          }
          
          // save valid date to data attribute for fallback reason
        
          if(BookingCalendar.validateDate($(this).val())) {
            var date = getDateFromFormat($(this).val(), BookingCalendar.local.dateFormat);
            $(this).data("date", new Date(date));
          }
        }
      });
    }
    
    this.setupEndDate = function() {
      
      $("#book .date #end_date").bind("keyup", function() {
        
        var value = $(this).val();
        
        if(BookingCalendar.validateDate(value)) {
          
          var date = new Date(getDateFromFormat(value, BookingCalendar.local.dateFormat));
          var start_date = getDateFromFormat($("#book .date #start_date").val(), BookingCalendar.local.dateFormat);
          var end_date = getDateFromFormat($("#book .date #end_date").val(), BookingCalendar.local.dateFormat);
          
          // set start_date + 1 when end_date is before the start_date
          
          if(end_date <= start_date) {
            var new_date = new Date(start_date).getTime() + BookingCalendar.oneDay;
            $(this).val(formatDate(new Date(new_date), BookingCalendar.local.dateFormat));
          }   
          
          // save valid date to data attribute for fallback reason
        
          if(BookingCalendar.validateDate($(this).val())) {
            var date = getDateFromFormat($(this).val(), BookingCalendar.local.dateFormat);
            $(this).data("date", new Date(date));
          }
        }
      });
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
          BookingCalendar.setData(true);
        }
      });
      
      $("#book .quantity .increase").click(function(){
        BookingCalendar.increaseQuantity();
        if(BookingCalendar.validateQuantity()) {
          BookingCalendar.setData(true);
        }
      });
      
      $("#book .quantity .decrease").click(function(){
        BookingCalendar.decreaseQuantity();
        if(BookingCalendar.validateQuantity()) {
          BookingCalendar.setData(true);
        }
      });
    }
    
    this.setupInventoryPoolSelector = function() {
      
      $("select#inventory_pool_id").change(function(){
        BookingCalendar.setData(true);
        
        $("#book .inventorypool .select .name").html($("#book .inventorypool option:selected").attr("name"));
        $("#book .inventorypool .select .address").html($("#book .inventorypool option:selected").attr("address"));
      });
      
      
    }

    this.setupFullcalendar = function() {
      
      BookingCalendar.calendar = $('#fullcalendar').fullCalendar({
        
          viewDisplay: BookingCalendar.viewDisplayFunction,
      
          header: {
              left: 'title',
              right: 'prev today next'
          },
          
          firstDay: BookingCalendar.firstDay
      });
      
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
          
          var colCnt = 7;
          var required_quantity = $('#fullcalendar').data("required_quantity");
          
          $("#fullcalendar .fc-content .fc-widget-content").each(function(index, element){
            var cell = {row: Math.floor(index/colCnt), col: index%colCnt};
            var date = view.cellDate(cell);
            var f1 = availability_dates.filter(function(x){
              var availability_date = new Date(x[0] * 1000);
              return (availability_date < date); // TODO <= ???
            });
            var available_quantity = (f1.length ? f1[f1.length-1][1] : 0);
            var class_names = (available_quantity >= required_quantity ? ["available", "unavailable"] : ["unavailable", "available"]);
            $(element).removeClass(class_names[1]).addClass(class_names[0]).find('div.fc-day-content > div').text(available_quantity);
          });
        }
    
    this.setData = function(render) {
    	var q = parseInt($("#book input#quantity").val());
    	var av = $("select#inventory_pool_id option:selected").data("availability_dates");
    	$('#fullcalendar').data("required_quantity", q).data("availability_dates", av);
    	if (render) $('#fullcalendar').fullCalendar('render');
    }
    
}