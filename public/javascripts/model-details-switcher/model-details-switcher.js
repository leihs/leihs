/*
 * Model Details Switcher
 *
 * This script provides functionalities to switch between viewing just a few and every detail
 *
 * @name Model Details Switcher
 * @author Sebastian Pape <email@sebastianpape.com>
*/

$(document).ready(function(){
	DetailsSwitcher.setupBindings();
});

var DetailsSwitcher = new DetailsSwitcher();

function DetailsSwitcher() {
    
    this.min = 7;
    this.max = 15;
    this.animationSpeed = 10;
    
    this.setupBindings = function() {
        if($("#model .details tr").length > DetailsSwitcher.min) {
            // hide details until min
            $("#model .details tr").each(function(index, value){
                if(index > DetailsSwitcher.min + 1) {
                    $(value).hide();
                }
            });
            
            // show and bind the showmore button
            $("#model .details .detailsswitcher .showmore").show();
            $("#model .details .detailsswitcher .showmore").bind("click", function() {
                
                // show more details animation
                var _delay = 0;
                $("#model .details tr").each(function(index, value){
                    if(index > DetailsSwitcher.min + 1) {
                        $(value).stop().delay(_delay).show(1);
                        _delay += DetailsSwitcher.animationSpeed;
                    }
                });
                
                // switch button to less
                $("#model .details .detailsswitcher .showmore").hide();
                $("#model .details .detailsswitcher .showless").show();
            });
            
            // bind the show less button
            DetailsSwitcher.bindShowLess($("#model .details .detailsswitcher .showless"));
            
            // show details switcher
            $("#model .details .detailsswitcher").show();
        }
    }
    
    this.bindShowLess = function(_object) {
        
        // bind the showless button
        $(_object).bind("click", function() {
            
            // show less details animation
            var _delay = 0;
            $("#model .details tr").each(function(index, value){
                if(index > DetailsSwitcher.min + 1) {
                    $(value).stop().delay(_delay).hide();
                    _delay += DetailsSwitcher.animationSpeed;
                }
            });
            
            // switch button to less
            $("#model .details .detailsswitcher .showless").hide();
            $("#model .details .detailsswitcher .showmore").show();
            
            // show details switcher
            $("#model .details .detailsswitcher").show();
        });
    }
}