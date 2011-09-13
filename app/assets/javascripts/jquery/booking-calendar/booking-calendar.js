/*
 * Booking Calendar
 *
 * This script provides functionalities for using a full calendar (by Adam Shaw) and combine it with item availability
 *
 * @name Booking Calendar
 * @author Sebastian Pape <email@sebastianpape.com>
 * @author Franco Sellitto (ZHdK)
*/

$(document).ready(function(){
	BookingCalendar.setup();
	
    var date = new Date();
    var d = date.getDate();
    var m = date.getMonth();
    var y = date.getFullYear();
    
    var calendar = $('#fullcalendar').fullCalendar({
        viewDisplay: function(view) {
		  	var availability_dates = $('#fullcalendar').data('availability_dates');
		  	if (!availability_dates) return false;
        	var colCnt = 7;
        	$("#fullcalendar .fc-content table tbody tr td").each(function(index, element){
				var cell = {row: Math.floor(index/colCnt), col: index%colCnt};
				var date = view.cellDate(cell);
	  			var f1 = availability_dates.filter(function(x){
	  			  var availability_date = new Date(x[0] * 1000);
	  			  return (availability_date < date); // TODO <= ???
	  			});
	  			var available_quantity = (f1.length ? f1[f1.length-1][1] : 0);
	  			$(element).find('div.fc-day-content > div').text(available_quantity);
        	});
	    },
    
        header: {
            left: 'prev',
            center: 'title',
            right: 'next'
        },
        
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
        events: [
            {
                title: '3',
                start: new Date(y, m, 1),
                end: new Date(y, m, 12)
            }
        ]
    });
});

var BookingCalendar = new BookingCalendar();

function BookingCalendar() {
    
    this.setup = function() {
    	BookingCalendar.set_data();
    	
    	var first_selected =  $("select#inventory_pool_id option:selected");
    	
		$("select#inventory_pool_id").change(function(){
 		  BookingCalendar.set_data(true);
	    });
    	
		$("#book form").bind("reset", function(){
		  first_selected.attr("selected", true);
		  BookingCalendar.set_data(true);
	    });
    }
    
    this.set_data = function(render) {
    	var av = $("select#inventory_pool_id option:selected").data("availability_dates");
    	$('#fullcalendar').data("availability_dates", av);
    	if (render) $('#fullcalendar').fullCalendar('render');
    }
    
}