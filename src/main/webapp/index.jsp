<html>
<head>
<meta http-equiv="Content-Type"
	content="application/xhtml+xml; charset=utf-8" />
<title>Force-Directed Layout</title>
<script type="text/javascript" src="/js/protovis-r3.2.js"></script>
<script type="text/javascript" src="/js/nodeHelpers.js"></script>

<script type="text/javascript" src="js/jquery-1.6.1.min.js"></script>
<script type="text/javascript" src="js/jquery-ui-1.8.13.custom.min.js"></script>
<link href="/css/overcast/jquery-ui-1.8.13.custom.css" rel="stylesheet"
	type="text/css" />
<link href="/css/base.css" rel="stylesheet" type="text/css" />


<script type="text/javascript"> 

var currentTimeouts = [];
var initialGraph = [];
var frameInformation = [];
var mouseOverNodeName;

$(document).ready(function() {
	
   $('#graph-selector-dropdown').change(function(ev) {
	   console.debug(ev);
	   
   });
	
	//hover states on the static widgets
	$('#dialog_link, ul#icons li').hover(
		function() { $(this).addClass('ui-state-hover'); }, 
		function() { $(this).removeClass('ui-state-hover'); }
	);
	
	$("#frameInfo").text("Date: " + initialGraph.date);
	
   $("#slider").slider({ 
	max: frameInformation.length - 1, 
	animate: true,
	change: function(event, ui) {
		if(event.button == 0) {
			stopAnimation();
			slideChange(ui.value, false);
		}
	}
	});
	
	$("#play").click(function() {
		var delta = 1800;
		var counter = 1;
		$("#slider").css("background", "#A0C575");
		for(var index = $('body').data('lastSliderIndex'); index < frameInformation.length; index++) {
			(function(index) {
				if (counter == 1) {
					currentTimeouts.push(setTimeout(function() { slideChange(index, true); }, counter));
				} else {
					currentTimeouts.push(setTimeout(function() { slideChange(index, true); }, delta * counter));
				}
				counter = counter + 1;
			})(index);
		}
	});
	
	$("#pause").click(stopAnimation);	
	
 });


function stopAnimation() {
	$("#slider").css("background", "");
	for	(index in currentTimeouts) {
		clearTimeout(currentTimeouts[index]);
	}	
}

function slideChange(index, updateSlider) {
	if(updateSlider) {
		$("#slider").slider("option", "value", index);		
	}
	var newFrameIndex = index;
	var oldFrameIndex = $('body').data('lastSliderIndex');
	$('body').data('lastSliderIndex', newFrameIndex);
	generateGraphForFrame(oldFrameIndex, newFrameIndex);
	$("#frameInfo").text("Date: " + frameInformation[newFrameIndex].date);
	$("#change-log").scrollTop(8000);
}

function createLogEntry(frameInfo) {
	var elem = "<li class=\"log-element\">";
	elem += "<span class=\"log-title\">Date: " + frameInfo.date + "</span>";
	elem += "<ul class=\"log-details\">";
	elem += "<li>Adding: " + printNodeNameList(frameInfo.add) + "</li>";
	elem += "<li>Deleting: " + printNodeNameList(frameInfo.del) + "</li>";
	elem += "</ul></li>";
	return elem;
}

function printNodeNameList(nodeList) {
	if(nodeList.length == 0) {
		return "-";
	} else {
		return jQuery.map(nodeList, function(n, i){ return (n.nodeName); }).join(", ");
	}
}

</script>
</head>

<body>
	<script type="text/javascript"> 

   loadGraphData("/js/initialGraph.js");
   
	function loadGraphData(jsonURL) {
		$.ajax({
		        type: "GET",
		        url: jsonURL,
		        async: false,
		        mimeType: 'application/json',
		        success: function(data) {
		        	  initialGraph = data.initialGraph;
		        	  frameInformation = data.frameInformation;
		        	  vis.reset();
		        	  vis.render();
		       }
		});
	}
	
	function transform() {
	    var t = this.transform().invert();
	    $('body').data('currentZoomLevel', t.x);
	    vis.render();
	}

	//initial values for animation controls
	$('body').data('currentZoomLevel', 1);
	$('body').data('lastSliderIndex', 0);

	var nodesInCurrentFrame = initialGraph.nodes; 
	var linksInCurrentFrame = initialGraph.links;

	var w = document.body.clientWidth,
	    h = document.body.clientHeight,
	    colors = pv.Colors.category10();

	var vis = new pv.Panel()
	    .width(w)
	    .height(h)
	    .fillStyle("#2F4D71")
	    .event("mousedown", pv.Behavior.pan())
	    .event("mousewheel", pv.Behavior.zoom(1))
	    .event("pan", transform)
	    .event("zoom", transform);

	var force = vis.add(pv.Layout.Force)
	    .nodes(initialGraph.nodes)
	    .links(initialGraph.links)
	    .springConstant(0.05)
		.chargeTheta(0.4)
		.dragConstant(0.009)
	    .chargeConstant(-100);

	force.link.add(pv.Line)
		.strokeStyle(function(d, p) {
			             if (p.sourceNode.nodeName == mouseOverNodeName || p.targetNode.nodeName ==  mouseOverNodeName) {
			            	return "black";
			            } else {
			            	return "#60B9CE";
			           }});

	force.node.add(pv.Dot)
	    .size(function(d) {
			return (d.linkDegree + 4) * Math.pow(this.scale, -1.5);
		})
	    .fillStyle(function(d) {
	    	 if(d.nodeName == mouseOverNodeName) {
	                return "black";
	            } else {
	                return "#909DAD";
	            }
	            })
	    .strokeStyle(function() {
			return this.fillStyle().darker();
		})
	    .lineWidth(1)
		   
	    .title(function(d) { 
			return d.nodeName; 
		})
	    .event("mouseover", function(node) {
	    	mouseOverNodeName = node.nodeName;
	    	vis.render();
		 })
		//.event("click", function(node) {
		//	console.debug(node.nodeName + " clicked");
		//	})
	    .event("mousedown", pv.Behavior.drag())
	    .event("drag", force)
	    .event("dblclick", console.debug("dblclick"));

	force.label.add(pv.Label)
	    //.bottom(0)
	    //.left(10)
		.textStyle("#FFF1DC")
		.textDecoration("underline")
	    .font(function(node) {
	            var fontSize = 12;
	            if (node.linkDegree * 0.5 > 20){
	                fontSize = 20;
	            }
	            else if (node.linkDegree * 0.5 < 12) {
	                fontSize = 12;
	            } else {
	                fontSize = node.linkDegree * 0.5;
	            }

	            return fontSize + "px sans-serif";
	        })
	    .text(function(node) {
	            var zoomLevel = $('body').data('currentZoomLevel');
	            var nodeDegree = node.linkDegree;
	            if (zoomLevel < -250) {
	                return "";
	            }
	            if (zoomLevel < 500 && nodeDegree > 50) {
	                return node.nodeName;
	            }
	            if (zoomLevel >= 500) {
	                return node.nodeName;
	            }
	            return "";
	        });

	vis.render();


</script>

    <div id="graph-selector" class="ui-base-box">
        <div class="control">Select your Graph:</div>
		<select id="graph-selector-dropdown" size="1">
		  <option value="1">Musicians / Bands</option>
		  <option value="2">Bands</option>
		  <option value="3">Modern Musicians and Bands</option>
		  <option value="4">Classical Musicians</option>
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

	<div id="change-log" class="ui-base-box">
		<div id="LogInfo" class="control">Change-Log</div>
		<ul></ul>
	</div>
	<div id="about-box" class="ui-base-box">
		<div class="control">About</div>
		<div class="ui-base-text">
			Based on ideas of Keiichi Nemoto, Peter Gloor and <a
				href="http://twitter.com/ret0">Reto Kleeb</a>. Realization by Reto
			Kleeb. Powered by <a href="http://vis.stanford.edu/protovis/">Protovis</a>
			/ <a href="http://jquery.com/">jQuery</a>. Data provided by <a
				href="http://www.wikipedia.org/">Wikipedia</a>.
		</div>

	</div>
</body>
</html>
