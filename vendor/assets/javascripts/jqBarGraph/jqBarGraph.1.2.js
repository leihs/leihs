/**
 * jqBarGraph - jQuery plugin - Extended
 * @version: 1.2 (2011/10/12)
 * @requires jQuery v1.2.2 or later 
 * @author Ivan Lazarevic
 ** @author Sebastian Pape
 * 
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 * 
 * @param data: arrayOfData                     // array of data for your graph
 * @param title: false                          // title of your graph, accept HTML
 * @param barSpace: 10                          // this is default space between bars in pixels
 * @param width: 400                            // default width of your graph ghhjgjhg
 * @param height: 200                                   //default height of your graph
 * @param color: '#000000'                      // if you don't send colors for your data this will be default bars color
 * @param colors: false                         // array of colors that will be used for your bars and legends
 * @param lbl: ''                               // if there is no label in your array
 * @param sort: false                           // sort your data before displaying graph, you can sort as 'asc' or 'desc'
 * @param position: 'bottom'                    // position of your bars, can be 'bottom' or 'top'. 'top' doesn't work for multi type
 * @param prefix: ''                            // text that will be shown before every label
 * @param postfix: ''                           // text that will be shown after every label
 * @param animate: true                         // if you don't need animated appereance change to false
 * @param speed: 2                              // speed of animation in seconds
 * @param legendWidth: 100                      // width of your legend box
 * @param legend: false                         // if you want legend change to true
 * @param legends: false                        // array for legend. for simple graph type legend will be extracted from labels if you don't set this
 * @param type: false                           // for multi array data default graph type is stacked, you can change to 'multi' for multi bar type
 * @param showValues: true                      // you can use this for multi and stacked type and it will show values of every bar part
 * @param showValuesColor: '#fff'               // color of font for values 
 * 
 * new params through extension
 * 
 * @param grid: true                            // enable or disable grid
 * @param gridSpace: 20                         // space between gridtext and graphs
 * @param gridAtMax: false                      // if enabled the highest grid starts at the highest value of given data
 * @param gridSections: 1                       // number of gridSections (space between to grid lines having value text)
 * @param gridColors: ["#444444", "#AAAAAA"]    // colors for the grid. second one is for intermediate grids.
 * @param interGrids: 1                         // number of intermediate grids (without value text) inside a grid section
 *
 * ***** EXAMPLE ****
 * 
 * $('#divForGraph').jqBarGraph({ data: arrayOfData });  
 * 
 * ******************
 * 
**/

(function($) {
	var opts = new Array;
	var level = new Array;
	
	$.fn.jqBarGraph = $.fn.jqbargraph = function(options){
	
	init = function(el){

		opts[el.id] = $.extend({}, $.fn.jqBarGraph.defaults, options);
		$(el).css({ 'width': opts[el.id].width, 'height': opts[el.id].height, 'position':'relative', 'text-align':'center' });
		doGraph(el);
    doGrid(el);

	};
	
	// sum of array elements
	sum = function(ar){
		total = 0;
		for(val in ar){
			total += ar[val];
		}
		return total.toFixed(2);
	};
	
	// count max value of array
	maxVal = function(ar){
		maxvalue = 0;
		for(var val in ar){
			value = ar[val][0];
			if(value instanceof Array) value = sum(value);	
			if (parseFloat(value) > parseFloat(maxvalue)) maxvalue=value;
		}	
		return maxvalue;	
	};

	// max value of multi array
	maxMulti = function(ar){
		maxvalue = 0;
		maxvalue2 = 0;
		
		for(var val in ar){
			ar2 = ar[val][0];
			
			for(var val2 in ar2){
				if(ar2[val2]>maxvalue2) maxvalue2 = ar2[val2];
			}

			if (maxvalue2>maxvalue) maxvalue=maxvalue2;
		}	
		return maxvalue;		
	};
	
	doGraph = function(el){
		
		arr = opts[el.id];
		data = arr.data;
		
		//check if array is bad or empty
		if(data == undefined) {
			$(el).html('There is not enought data for graph');
			return;
		}
		
		//sorting ascending or descending
		if(arr.sort == 'asc') data.sort(sortNumberAsc);
		if(arr.sort == 'desc') data.sort(sortNumberDesc);
		
		legend = '';
		prefix = arr.prefix;
		postfix = arr.postfix;
		space = arr.barSpace; //space between bars
		legendWidth = arr.legend ? arr.legendWidth : 0; //width of legend box
		gridSpace = arr.gridSpace;
		fieldWidth = ($(el).width()-legendWidth-gridSpace)/data.length; //width of bar
		totalHeight =  $(el).height(); //total height of graph box
		var leg = new Array(); //legends array
		
		//max value in data, I use this to calculate height of bar
		max = maxVal(data);
		colPosition = 0; // for printing colors on simple bar graph

 		for(var val in data){
 			
 			valueData = data[val][0];
 			if (valueData instanceof Array) 
 				value = parseFloat(sum(valueData));
 			else
 				value = parseFloat(valueData);
 			
 			lbl = data[val][1];
 			color = data[val][2];
			unique = val+el.id; //unique identifier
			
 			if (color == undefined && arr.colors == false) 
 				color = arr.color;
 				
 			if (arr.colors && !color){
 				colorsCounter = arr.colors.length;
 				if (colorsCounter == colPosition) colPosition = 0;
 				color = arr.colors[colPosition];
 				colPosition++;
 			}
 			
 			if(arr.type == 'multi') color = 'none';
 				
 			if (lbl == undefined) lbl = arr.lbl;
 		
 			out  = "<div class='graphField"+el.id+"' id='graphField"+unique+"' style='position: absolute'>";
 			
 			if(lbl.value) {
 			  out += "<div class='graphValue"+el.id+"' id='graphValue"+unique+"'>"+lbl.value+"</div>";
 			} else {
        out += "<div class='graphValue"+el.id+"' id='graphValue"+unique+"'>"+prefix+value+postfix+"</div>"; 			  
 			}
 			out += "<div class='graphBar"+el.id+"' id='graphFieldBar"+unique+"' style='background-color:"+color+";position: relative; overflow: hidden;'></div>";

			// if there is no legend or exist legends display lbl at the bottom
 			if(!arr.legend || arr.legends)
 				out += "<div class='graphLabel"+el.id+"' id='graphLabel"+unique+"'>"+lbl.name+"</div>";
 			out += "</div>";
 			
			$(el).append(out);
 			
 			//size of bar
 			totalHeightBar = totalHeight - $('.graphLabel'+el.id).outerHeight() - $('.graphValue'+el.id).outerHeight(); 
 			fieldHeight = (totalHeightBar*value)/max;	
 			$('#graphField'+unique).css({ 
 				'left': (fieldWidth)*val+gridSpace, 
 				'width': fieldWidth-space, 
 				'margin-left': space/2,
 				'margin-right': space/2});
 	
 			// multi array
 			if(valueData instanceof Array){
 				
				if(arr.type=="multi"){
					maxe = maxMulti(data);
					totalHeightBar = fieldHeight = totalHeight - $('.graphLabel'+el.id).height();
					$('.graphValue'+el.id).remove();
				} else {
					maxe = max;
				}
				
 				for (i in valueData){
 					heig = totalHeightBar*valueData[i]/maxe;
 					wid = parseInt((fieldWidth-space)/valueData.length);
 					sv = ''; // show values
 					fs = 0; // font size
 					valueElement = '';
 					if (arr.showValues && valueData[i] != 0 && sum(valueData) != valueData[i]){
 						sv = arr.prefix+valueData[i]+arr.postfix;
 						fs = 12; // font-size is 0 if showValues = false
 						valueElement = "<span class='text'>"+sv+"</span>";
 					}
 					o = "<div class='subBars"+el.id+"' style='height:"+heig+"px; background-color: "+arr.colors[i]+"; left:"+wid*i+"px; color:"+arr.showValuesColor+"; font-size:"+fs+"px' ></div>";
 					$('#graphFieldBar'+unique).prepend(o);
 				}
 			}
 			
 			if(arr.type=='multi')
 				$('.subBars'+el.id).css({ 'width': wid, 'position': 'absolute', 'bottom': 0 });
 
 			//position of bars
 			if(arr.position == 'bottom') $('.graphField'+el.id).css('bottom',0);

			//creating legend array from lbl if there is no legends param
 			if(!arr.legends)
 				leg.push([ color, lbl, el.id, unique ]); 
 			
 			// animated apearing
 			if(arr.animate){
 				$('#graphFieldBar'+unique).css({ 'height' : 0 });
 				$('#graphFieldBar'+unique).animate({'height': fieldHeight},arr.speed*1000);
 			} else {
 				$('#graphFieldBar'+unique).css({'height': fieldHeight});
 			}
 			
 		}
 			
 		//creating legend array from legends param
 		for(var l in arr.legends){
 			leg.push([ arr.colors[l], arr.legends[l], el.id, l ]);
 		}
 		
 		createLegend(leg); // create legend from array
 		
 		//position of legend
 		if(arr.legend){
			$(el).append("<div id='legendHolder"+unique+"'></div>");
	 		$('#legendHolder'+unique).css({ 'width': legendWidth, 'float': 'right', 'text-align' : 'left'});
	 		$('#legendHolder'+unique).append(legend);
	 		$('.legendBar'+el.id).css({ 'float':'left', 'margin': 3, 'height': 12, 'width': 20, 'font-size': 0});
 		}
 		
 		//position of title
 		if(arr.title){
 			$(el).wrap("<div id='graphHolder"+unique+"'></div>");
 			$('#graphHolder'+unique).prepend(arr.title).css({ 'width' : arr.width+'px', 'text-align' : 'center' });
 		}
 		
	};

	doGrid = function(el){
	  
    //check options
	  options = opts[el.id];
    if(!options.grid) {return}
    
    //prepare data
    arr = opts[el.id];
    data = arr.data;
    
    //get highest value in data array
    var max = parseFloat(maxVal(data));
    
    //compute highest data grid value
    var highest = Math.floor( max / Math.pow(10, max.toString().length-1) );
        highest = highest * Math.pow(10, max.toString().length-1);
        highest = (arr.gridAtMax) ? max : highest;
    
    //preparing grid lines
    var gridstep = highest / arr.gridSections;
    var gridlines = [];
    var interstep = highest / arr.gridSections / (arr.interGrids+1)
    var intergrids = [];
    
        for(var i = 0; i < arr.gridSections; i++){
         gridlines.push( Math.round(gridstep*i) );
         
         for(var i2 = 1; i2 <= arr.interGrids; i2++) {
           intergrids.push( gridlines[i] + interstep*i2 );
         }
        }
        
        gridlines.push(highest);
    var gridColors = arr.gridColors;
        
    //compute margins
    var marginb = $(el).find(".graphLabel").first().outerHeight();
    var margint = $(el).find(".graphValue").first().outerHeight();
        
    //generating grid
    var grid = "<div class='bar-grid' style='position:absolute; height:"+options.height+"px; width:"+options.width+"px;'>";
        
        for(var i = 0; i < gridlines.length; i++){
          
          y = (max - gridlines[i]) / max;
          y = (y === -Infinity) ? 0 : y;
          y = y * (options.height-marginb-margint) + margint;
          
          grid += "<div class='grid-line' style='border-top: 1px solid "+gridColors[0]+";display:block; width: "+options.width+"px;position:absolute; top:"+y+"px'>";
          grid += "<span class='grid-text' style='position: absolute; left: 0; top:-5px;'></span>";
          grid += "<hr/>";
          grid += "</div>";
        }
        
        for(var i = 0; i < intergrids.length; i++){
          
          y = (max - intergrids[i]) / max;
          y = (y === -Infinity) ? 0 : y;
          y = y * (options.height-marginb-margint) + margint;
          
          grid += "<div class='grid-line grid-intermediate' style='border-top: 1px solid "+gridColors[1]+";opacity: 0.5;block; width: "+options.width+"px;position:absolute; top:"+y+"px'>";
          grid += "<hr/>";
          grid += "</div>";
        }
        
        grid +="</div>"
        
    //add grid to destinated element
    $(el).prepend(grid);
	};

	//creating legend from array
	createLegend = function(legendArr){
		legend = '';
		for(var val in legendArr){
	 			legend += "<div id='legend"+legendArr[val][3]+"' style='overflow: hidden; zoom: 1;'>";
	 			legend += "<div class='legendBar"+legendArr[val][2]+"' id='legendColor"+legendArr[val][3]+"' style='background-color:"+legendArr[val][0]+"'></div>";
	 			legend += "<div class='legendLabel"+legendArr[val][2]+"' id='graphLabel"+unique+"'>"+legendArr[val][1]+"</div>";
	 			legend += "</div>";			
		}
	};

	this.each (
		function()
		{ init(this); }
	)
	
};

	// default values
	$.fn.jqBarGraph.defaults = {	
		barSpace: 10,
		width: 400,
		height: 300,
		color: '#000000',
		colors: false,
		lbl: '',
		sort: false, // 'asc' or 'desc'
		position: 'bottom', // or 'top' doesn't work for multi type
		prefix: '',
		postfix: '',
		animate: true,
		speed: 1.5,
		legendWidth: 100,
		legend: false,
		legends: false,
		type: false, // or 'multi'
		showValues: true,
		showValuesColor: '#fff',
		title: false,
		grid: true,
		gridSpace: 20,
		gridAtMax: false,
		gridSections: 2,
    gridColors: ["#444444", "#AAAAAA"],
		interGrids: 1
	};
	
	
	//sorting functions
	function sortNumberAsc(a,b){
		if (a[0]<b[0]) return -1;
		if (a[0]>b[0]) return 1;
		return 0;
	}
	
	function sortNumberDesc(a,b){
		if (a[0]>b[0]) return -1;
		if (a[0]<b[0]) return 1;
		return 0;
	}	

})(jQuery);