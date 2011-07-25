/*
 * Models List Sort
 *
 * This script provides functionalities for sorting the items on the model-index-view
 *
 * @name Models List Sort
 * @author Sebastian Pape <email@sebastianpape.com>
*/

$(document).ready(function(){
	ModelsSort.setupBindings();
});

var ModelsSort = new ModelsSort();

function ModelsSort() {
    
    this.setupBindings = function() {
        // ON CHANGE SORT METHOD
        $('#topfilter .sort select').bind('change', function(){
            var _value = $(this).val();
            var _values = _value.split(" ");
            var _items = $("#modellist .item");
            
            if(_values[0] == "name") {
                if(_values[1] == "ASC") {
                    _items.sort(ModelsSort.sortNameAlphabeticaly).appendTo('#modellist');
                } else if(_values[1] == "DESC") {
                    _items.sort(ModelsSort.sortNameAlphabeticalyReverse).appendTo('#modellist');
                }
            } else if(_values[0] == "manufacturer") {
                if(_values[1] == "ASC") {
                    _items.sort(ModelsSort.sortManufacturerAlphabeticaly).appendTo('#modellist');
                } else if(_values[1] == "DESC") {
                    _items.sort(ModelsSort.sortManufacturerAlphabeticalyReverse).appendTo('#modellist');
                }
            }
        });
    }
    
    this.sortNameAlphabeticaly = function(a,b){
        return $(a).find(".name a").html().toUpperCase() > $(b).find(".name a").html().toUpperCase() ? 1 : -1;
    }
    
    this.sortNameAlphabeticalyReverse = function(a,b){
        return $(a).find(".name a").html().toUpperCase() < $(b).find(".name a").html().toUpperCase() ? 1 : -1;
    }
    
    this.sortManufacturerAlphabeticaly = function(a,b){
        return $(a).find(".manufacturer a").html().toUpperCase() > $(b).find(".manufacturer a").html().toUpperCase() ? 1 : -1;
    }
    
    this.sortManufacturerAlphabeticalyReverse = function(a,b){
        return $(a).find(".manufacturer a").html().toUpperCase() < $(b).find(".manufacturer a").html().toUpperCase() ? 1 : -1;
    }

}