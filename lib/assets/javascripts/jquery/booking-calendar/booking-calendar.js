/*
 * Booking Calendar
 *
 * This script provides functionalities for using a full calendar (by Adam Shaw) and combine it with item availability
 *
 * @name Booking Calendar
 * @author Sebastian Pape <email@sebastianpape.com>
*/

$(document).ready(function(){
    var date = new Date();
    var d = date.getDate();
    var m = date.getMonth();
    var y = date.getFullYear();
    
    var calendar = $('#calendar').fullCalendar({
        
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