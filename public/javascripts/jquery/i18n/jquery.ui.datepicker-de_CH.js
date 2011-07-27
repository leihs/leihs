/* Swiss-German initialisation for the jQuery UI date picker plugin. */
/* By Douglas Jose & Juerg Meier. */
jQuery(function($){
	$.datepicker.regional['de-CH'] = {
		closeText: 'Schliessen',
		prevText: 'Vorherigen Monat',
		nextText: 'Nächsten Monat',
		currentText: 'heute',
		monthNames: ['Januar','Februar','März','April','Mai','Juni',
		'Juli','August','September','Oktober','November','Dezember'],
		monthNamesShort: ['Jan','Feb','Mär','Apr','Mai','Jun',
		'Jul','Aug','Sep','Okt','Nov','Dez'],
		dayNames: ['Sonntag','Montag','Dienstag','Mittwoch','Donnerstag','Freitag','Samstag'],
		dayNamesShort: ['So','Mo','Di','Mi','Do','Fr','Sa'],
		dayNamesMin: ['So','Mo','Di','Mi','Do','Fr','Sa'],
		weekHeader: 'Wo',
		dateFormat: 'dd.mm.y'};
	$.datepicker.setDefaults($.datepicker.regional['de-CH']);
});