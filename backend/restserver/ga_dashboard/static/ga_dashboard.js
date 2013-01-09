  // Load the Visualization API and the piechart package.
  google.load('visualization', '1.0', {'packages':['corechart', 'table']});

  // Set a callback to run when the Google Visualization API is loaded.
  google.setOnLoadCallback(drawDashboard);

  
  function drawDashboard() {
    var dashboard = $.parseJSON( $('#dashboard_data').val() );
	$.each(dashboard.charts, function(index, chart){
        try {
        	var data = initData(chart);
        }
        catch(e) {
  			console.log('Chart parsing error: \'' + e + '\'');
        	return true;
        }
		
		drawChart(chart.type, data, chart.options);
	})
  }
  
  function initData(chart) {
  	var data;
  	switch(chart.type){
  		case 'PieChart':
  		case 'BarChart':
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
  			$.each(chart.data, function(index, subchart_data){
  				try{
  					subchart = initData(subchart_data);
  				}catch(e){
  					console.log('\'Tables\' parsing error: ' + e);
  					return true;
  				}
  				data.push(subchart);
  			});
  			break;
  		default:
  			throw 'Unexpectable chart type [' + chart.type + ']'; 
  	}
  	
  	return data;
  }
  
  function drawChart(type, data, options){
  	var id = (type + '_' + new Date().getTime()).replace(/ /g, '');
  	$('<div/>', {
  		'id':id,
  		'style':'float:left; width:33%;'
  	}).appendTo('#charts_container');
  	try{
  		var chart = new google.visualization[ type ] ( $('#'+id)[0] );
  	} catch(e){
  		if (/visualization is not defined/g.test(e))
  			throw 'Unsupported by GoogleChartTools type \'' + type + '\'';
  		else
  			throw 'Exception on drawChart method:\'' + e + '\'';
  	}
  	if (type == 'Tables') {
  		$('#'+id).append($('h1').html(options.title));
  	}
    chart.draw(data, options);
  }
