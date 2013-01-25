  var __special_charts =  ['Metric', 'Tables']
  var load_attempts = 3;
  // Load the Visualization API and the piechart package.
  google.load('visualization', '1.0', {'packages':['corechart', 'table']});

  // Set a callback to run when the Google Visualization API is loaded.
  google.setOnLoadCallback(drawDashboard);

  
  function drawDashboard() {
  	
    var dashboard = $.parseJSON( $('#dashboard_data').val() );
    if (dashboard.charts.length > 0){
    	$('#blocker').show();
  		var ajax_counter = 0;
  		draw_chart_by_index(0, dashboard.charts);
    }
  }
  
  function draw_chart_by_index(index, charts, err_count){
  	if (typeof err_count == 'undefined'){
  		err_count = 0;
  	}
	if (index<charts.length) {
		chart = charts[index];
		$.ajax({
			url: $(location).attr('pathname') + '?chart=' + chart,
			dataType: 'json',
			success: function(data){
				chart = data;
		        try {
		        	var prepared_data = initData(chart);
		        }
		        catch(e) {
		  			console.log('Chart parsing error: \'' + e + '\'');
		        	return true;
		        }
				drawChart(chart, prepared_data);
				
				draw_chart_by_index(++index, charts); //draw next chart					
			},
			error:function(){
				if (err_count>load_attempts-1){
					console.log('Error: ' + chart + ' chart failed');
					draw_chart_by_index(++index, charts); //draw next chart					
				} else {
					err_count++;
					console.log('Loading ' + chart + '... [' + err_count + '] attempt');
					draw_chart_by_index(index, charts, err_count); //try again					
				}
			},
			complete: function(){
				if (index == charts.length - 1) $('#blocker').hide()
			}
		});
	}
  }
  
  function initData(chart) {
  	var data;
  	switch(chart.type){
  		case 'Metric':
  			data   = chart.data;
  			break;
  			
  		case 'PieChart':
  		case 'BarChart':
  		case 'ColumnChart':
  			data = google.visualization.arrayToDataTable(chart.data);
  			break;
  			
  		case 'Table':
  			data = new google.visualization.DataTable();
  			$.each(chart.data.columns, function(index, column){
  				data.addColumn(column.type, column.name);
  			});
  			data.addRows(chart.data.rows);
  			break;
  			
  		case 'Tables':
  			data = undefined;
  			$.each(chart.data, function(index, subchart_data){
  				try{
  					subchart = initData(subchart_data);
  				}catch(e){
  					console.log('\'Tables\' parsing error: ' + e);
  					return true;
  				}
  				chart.data[index].prepared_data = subchart;
  			});
  			break;
  		default:
  			throw 'Unexpectable chart type [' + chart.type + ']'; 
  	}
  	
  	return data;
  }
  
  function drawGCT(container, chart, prepared_data){
	try{
		var GCTchart = new google.visualization[ chart.type ] ( container[0] );
	} catch(e){
		if (/visualization is not defined/g.test(e))
			throw 'Unsupported by GoogleChartTools type \'' + chart.type + '\'';
		else
			throw 'Exception on drawChart method:\'' + e + '\'';
	}
	
	var options = (chart.type == 'Table') ? null : chart.options;
	
	GCTchart.draw(prepared_data, options);
  }
  
  function drawSpecial(container, chart, prepared_data){
  	switch(chart.type){
  		case 'Metric':
	  		$('<text/>', {
	  			'text':chart.options.title,
	  			'css': { 'font-family':'Arial', 'font-size'  : '10px', 'font-weight': 'bold' }
	  		})
	  		.appendTo(container);
	  		$('<div/>', {
	  			'text' : prepared_data,
	  			'class': 'metric'
	  		})
	  		.appendTo(container);
	  		return true;
  		break;
  		case 'Tables':
  			var menu = $(container).append('<ul/>')
  			$.each(chart.data, function(index, subchart){
  				var tab_id = 'tab' + index;
  				$('<li/>').append(
  					$('<a/>', {
  						'href': '#' + tab_id,
  						'text': subchart.options.title
  					})
  				)
  				.appendTo($(container).children('ul'));
  				
  				var subchart_container
	  				= $('<div/>', {'id':tab_id})
	  					.appendTo(container);
	  			
	  			drawGCT(subchart_container, subchart, subchart.prepared_data);
  			});
			$(container).tabs();
  		break;
  		default:
  			throw 'Unexpected chart type ' + chart.type;
  	}
  }
  
  function placeContainer(chart){
  	var id = (chart.type + '_' + new Date().getTime()).replace(/ /g, '');
  	var container =
	  	$('<div/>', {
	  		'id' : id,
	  		'css': { 'width':chart.options.width },
	  		'class': 'chart_container'
	  	})
	  	.appendTo('#charts_container');
	
  	//Create subcontainer for Tables
  	if (chart.type == 'Table'){
  		absolute_width = $(container).width() + 'px';
  		
  		return $('<div/>', {
  					'css':{'width' : absolute_width}
  				}).appendTo(container);
  	}
  	
  	return container;
  }
  
  function drawChart(chart, prepared_data){
  	var container = placeContainer(chart);
  	
  	if ($.inArray(chart.type, __special_charts) > -1) {
  		drawSpecial(container, chart, prepared_data);
  	} else{
  		drawGCT(container, chart, prepared_data);
  	}
  		
  	if (chart.type == 'Table' || chart.type == 'Tables') {
  		title_container = (chart.type == 'Table') ? $(container).parent() : container
  		$('<text/>', {
  			'text':chart.options.title,
  			'css': { 'font-family':'Arial', 'font-size'  : '10px', 'font-weight': 'bold' }
  		})
  		.prependTo(title_container);
  	}
  }
