var i18n = new i18n();

i18n.selected = i18n.locales['de-GB']; // which is default

function i18n() {
 
  this.selected;
 
  this.locales = [];
  
  this.locales['de-CH'] = {
  
    bookingcalendar: {
       dateFormat: "dd.MM.yyyy" //for example: dd.MM.yyyy
    },
    
    compacthistory: {
      dateFormat: "dd.MM.yyyy" //for example: dd.MM.yyyy
    },
    
    datepicker: {
      closeText: 'schliessen',
      prevText: '&lt;',
      nextText: '&gt;',
      currentText: 'heute',
      monthNames: ['Januar','Februar','März','April','Mai','Juni',
      'Juli','August','September','Oktober','November','Dezember'],
      monthNamesShort: ['Jan','Feb','Mär','Apr','Mai','Jun',
      'Jul','Aug','Sep','Okt','Nov','Dez'],
      dayNames: ['Sonntag','Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag'],
      dayNamesShort: ['So','Mo','Di','Mi','Do','Fr','Sa'],
      dayNamesMin: ['So','Mo','Di','Mi','Do','Fr','Sa'],
      weekHeader: 'Wo',
      dateFormat: 'dd.mm.y', //note jquery uses small m for months
      firstDay: 1,
      isRTL: false,
      showMonthAfterYear: false,
      yearSuffix: ''
    }
  };
  
  this.locales['en-US'] = {
  
    bookingcalendar: {
       dateFormat: "MM/dd/yyyy" //for example: MM.dd.yyyy
    },
    
    compacthistory: {
      dateFormat: "MM/dd/yyyy" //for example: dd.MM.yyyy
    },
    
    datepicker: {
      closeText: 'Done',
      prevText: '&lt;',
      nextText: '&gt;',
      currentText: 'Today',
      monthNames: ['January','February','March','April','May','June',
      'July','August','September','October','November','December'],
      monthNamesShort: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      dayNames: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
      dayNamesShort: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      dayNamesMin: ['Su','Mo','Tu','We','Th','Fr','Sa'],
      weekHeader: 'Wk',
      dateFormat: 'mm/dd/y', //note jquery uses small m for months
      firstDay: 0,
      isRTL: false,
      showMonthAfterYear: false,
      yearSuffix: ''
    }
  };
  
  this.locales['en-GB'] = {
  
    bookingcalendar: {
       dateFormat: "dd/MM/yyyy" //for example: MM.dd.yyyy
    },
    
    compacthistory: {
      dateFormat: "dd/MM/yyyy" //for example: dd.MM.yyyy
    },
    
    datepicker: {
      closeText: 'Done',
      prevText: '&lt;',
      nextText: '&gt;',
      currentText: 'Today',
      monthNames: ['January','February','March','April','May','June',
      'July','August','September','October','November','December'],
      monthNamesShort: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      dayNames: ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'],
      dayNamesShort: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
      dayNamesMin: ['Su','Mo','Tu','We','Th','Fr','Sa'],
      weekHeader: 'Wk',
      dateFormat: 'dd/mm/y', //note jquery uses small m for months
      firstDay: 0,
      isRTL: false,
      showMonthAfterYear: false,
      yearSuffix: ''
    }
  };
}