$(document).ready(function(){
  
	BookingCalendar.setup();
	
});

var BookingCalendar = new BookingCalendar();

function BookingCalendar() {
    
    this.setup = function() {
      
      BookingCalendar.setupFullcalendar();
      
    	BookingCalendar.set_data(true);
    	
  		$("select#inventory_pool_id").change(function(){
   		  BookingCalendar.set_data(true);
	    });
  
  		$("#book input#quantity").keyup(function(){
   		  BookingCalendar.set_data(true);
	    });
    }
    
    this.setupFullcalendar = function() {
      
      var date = new Date();
      var d = date.getDate();
      var m = date.getMonth();
      var y = date.getFullYear();
    
      var calendar = $('#fullcalendar').fullCalendar({
          viewDisplay: function(view) {
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
        },
      
          header: {
              left: 'title',
              right: 'prev today next'
          },
          
          firstDay: 1,
          
          selectable: true,
          selectHelper: true,
          select: function(start, end, allDay) {
              var title = prompt('Event Title:');
              if (title) {
                  calendar.fullCalendar('renderEvent',
                      {
                          title: title,
                          start: start,
                          end: end,
                          allDay: allDay
                      },
                      true // make the event "stick"
                  );
              }
              calendar.fullCalendar('unselect');
          },
          
          editable: false,
      });
      
    }
    
    this.set_data = function(render) {
    	var q = parseInt($("#book input#quantity").val());
    	var av = $("select#inventory_pool_id option:selected").data("availability_dates");
    	$('#fullcalendar').data("required_quantity", q).data("availability_dates", av);
    	if (render) $('#fullcalendar').fullCalendar('render');
    }
    
}