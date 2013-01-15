  var __special_charts =  ['Metric', 'Tables']
  // Load the Visualization API and the piechart package.
  google.load('visualization', '1.0', {'packages':['corechart', 'table']});

  // Set a callback to run when the Google Visualization API is loaded.
  google.setOnLoadCallback(drawDashboard);

  
  function drawDashboard() {
    var dashboard = $.parseJSON( $('#dashboard_data').val() );
	$.each(dashboard.charts, function(index, chart){
        try {
        	var prepared_data = initData(chart);
        }
        catch(e) {
  			console.log('Chart parsing error: \'' + e + '\'');
        	return true;
        }
		
		drawChart(chart, prepared_data);
	})
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
		
	GCTchart.draw(prepared_data, chart.options);
	

	$('.google-visualization-table-table').css('width', '100%')
	.parent('div').css('width', '100%');
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
  
  function drawChart(chart, prepared_data){
  	var id = (chart.type + '_' + new Date().getTime()).replace(/ /g, '');
  	var container =
	  	$('<div/>', {
	  		'id' : id,
	  		'css': { 'width':chart.options.width },
	  		'class': 'chart_container'
	  	})
	  	.appendTo('#charts_container');
  	
  	if ($.inArray(chart.type, __special_charts) > -1) {
  		drawSpecial(container, chart, prepared_data);
  	} else{
  		drawGCT(container, chart, prepared_data);
  	}
  		
  	if (chart.type == 'Table' || chart.type == 'Tables') {
  		$('<text/>', {
  			'text':chart.options.title,
  			'css': { 'font-family':'Arial', 'font-size'  : '10px', 'font-weight': 'bold' }
  		})
  		.prependTo(container);
  	}
  }
