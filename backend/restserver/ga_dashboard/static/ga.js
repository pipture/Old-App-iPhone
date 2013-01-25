var _gaq = _gaq || [];
var account = 'UA-27681421-' + ( typeof production != 'undefined' && production ? '2' : '1' );

_gaq.push(['_setAccount', account]);
_gaq.push(['_trackPageview']);

_gaq.push(['_setCustomVar', 2, 'EpisodeId', video_id.toString()]);
_gaq.push(['_setCustomVar', 3, series_id.toString(), album_id.toString()]);

if (album_purchase_status){
	_gaq.push(['_setCustomVar', 4, 'PurchaseStatus', album_purchase_status]);
}

_gaq.push(['_trackEvent','Video', 'Play', video_id.toString()]);    		

(function() {
	var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
	ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
	var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s  );
})();
