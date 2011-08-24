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
    var date = new Date();
    var d = date.getDate();
    var m = date.getMonth();
    var y = date.getFullYear();
    
    var calendar = $('#fullcalendar').fullCalendar({
        viewDisplay: function(view) {
		  	var availability_dates = $('#fullcalendar').data('availability_dates');
        	var colCnt = 7;
        	$("#fullcalendar .fc-content table tbody tr td").each(function(index, element){
				var cell = {row: Math.floor(index/colCnt), col: index%colCnt};
				var date = view.cellDate(cell);
	  			// TODO currently only works for first inventory_pool
	  			//var f1 = availability_dates.filter(function(x){
	  			var f1 = availability_dates[0].availability.filter(function(x){
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
    
    
}