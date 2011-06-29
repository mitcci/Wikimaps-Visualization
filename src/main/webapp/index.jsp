<html lang="en"> 

<head>
<meta http-equiv="Content-Type" content="application/xhtml+xml; charset=utf-8" />
<title>Wiki Map Project</title>

<script type="text/javascript" src="/js/protovis.min.js"></script>
<script type="text/javascript" src="/js/nodeHelpers.js"></script>
<script type="text/javascript" src="/js/protovis-setup.js"></script>

<script type="text/javascript" src="js/jquery-1.6.1.min.js"></script>
<script type="text/javascript" src="js/jquery-ui-1.8.13.custom.min.js"></script>

<link href="/css/overcast/jquery-ui-1.8.13.custom.css" rel="stylesheet" type="text/css" />
<link href="/css/base.css" rel="stylesheet" type="text/css" />

<script type="text/javascript"> 
var currentTimeouts = [];
var initialGraph = [];
var frameInformation = [];
var mouseOverNodeName;
var nodesInCurrentFrame = []; 
var linksInCurrentFrame = [];
var force;
var vis;

$(document).ready(function() {
	loadGraphData("/js/initialGraph_CLASSICAL_MUSIC.js");
	attachEventHandlers();
	//initial values for animation controls
	$('body').data('currentZoomLevel', 1);
	$('body').data('lastSliderIndex', 0);
	nodesInCurrentFrame = initialGraph.nodes; 
	linksInCurrentFrame = initialGraph.links;
    initializeCompletePanel();
});
</script>

</head>

<body>
    <div id="boxes-left" class="box-container">

	    <div id="graph-selector" class="ui-base-box">
	        <div class="control">Select your Graph:</div>
			<select id="graph-selector-dropdown" size="1">
			  <option value="/js/initialGraph_CLASSICAL_MUSIC.js">Classical Musicians</option>
			  <option value="/js/initialGraph_CLASSICAL_MUSIC_ENGLISH_MUSIC_MUSIC_GROUPS.js">Classical- , Modern-Musicians and Bands</option>
			  <option value="/js/initialGraph_ENGLISH_MUSIC.js">Modern Musicians</option>
			  <option value="/js/initialGraph_ENGLISH_MUSIC_MUSIC_GROUPS.js">Modern Musicians and Bands</option>
			</select>
	    </div>
	
		<div id="animation-controls" class="ui-base-box">
			<div class="control" id="frameInfo">Date:</div>
	
			<div class="slider-wrapper">
				<div id="slider">&nbsp;</div>
			</div>
			<ul class="ui-widget ui-helper-clearfix" id="icons">
				<li id="play" title=".ui-icon-play"
					class="ui-state-default ui-corner-all ui-state-hover"><span
					class="ui-icon ui-icon-play"></span>
				</li>
				<li id="pause" title=".ui-icon-pause"
					class="ui-state-default ui-corner-all ui-state-hover"><span
					class="ui-icon ui-icon-pause"></span>
				</li>
			</ul>
	
		</div>
		
		<div id="zoom-control" class="ui-base-box helper-box-compressed">
            <div id="LogInfo" class="control">Zoom-Controls:
	            <ul class="ui-widget ui-helper-clearfix top-aligned-button-list zoom-button-list" id="icons">
		            <li id="ui-icon-zoomin" title=".ui-icon-zoomin" class="ui-state-default ui-corner-all ui-state-hover">
		                <span class="ui-icon ui-icon-zoomin"></span>
		            </li>
		            <li id="ui-icon-zoomout" title=".ui-icon-zoomout" class="ui-state-default ui-corner-all ui-state-hover">
		                <span class="ui-icon ui-icon-zoomout"></span>
		            </li>
	            </ul>
            </div>
        </div>
	
		<div id="change-log" class="ui-base-box">
			<div id="LogInfo" class="control">Change-Log:</div>
			<ul></ul>
		</div>
		<div id="usageHints" class="ui-base-box helper-box-compressed">
            <div class="control">Usage Hints:
            <ul class="ui-widget ui-helper-clearfix top-aligned-button-list"  id="icons">
                <li class="ui-state-default ui-corner-all plus-minus-icon" title=".ui-icon-plusthick"><span class="ui-icon ui-icon-plusthick"></span></li> 
            </ul>
            </div>
            <ul>
                <li>Start and Stop the animation using the player controls</li>
                <li>Drag the slider to get to a specific point in time</li>
                <li>Hover over nodes to highlight the nodes connections and for a chance to learn more</li>
                <li>Use your scroll-wheel to zoom in and out</li>
                <li>Drage to complete graph around for fun</li>
                <li>Drag the nodes around for fun</li>
            </ul>   
        </div>
        
		<div id="about-box" class="ui-base-box helper-box-compressed">
			<div class="control">About:
			 <ul class="ui-widget ui-helper-clearfix top-aligned-button-list"  id="icons">
                <li class="ui-state-default ui-corner-all plus-minus-icon" title=".ui-icon-plusthick"><span class="ui-icon ui-icon-plusthick"></span></li> 
            </ul>
			</div>
			<div class="ui-base-text">
				Based on ideas of Keiichi Nemoto, Peter Gloor and <a
					href="http://twitter.com/ret0">Reto Kleeb</a>. Realization by Reto
				Kleeb. Powered by <a href="http://vis.stanford.edu/protovis/">Protovis</a>
				/ <a href="http://jquery.com/">jQuery</a>. Data provided by <a
					href="http://www.wikipedia.org/">Wikipedia</a>.
			</div>
		</div>
	</div>
	
	<div id="boxes-right" class="box-container">
		<div id="additionalNodeInfo" class="ui-base-box">
            <div class="control">Read more about </div> 
		</div>
	</div>
	
	
</body>
</html>
