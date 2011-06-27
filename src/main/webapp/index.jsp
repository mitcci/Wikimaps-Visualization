

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
var nodesInCurrentFrame = []; 
var linksInCurrentFrame = [];
var force;
var vis;

function toggleInfoBox(elementID, reference) {
	  $(reference).parents(elementID).toggleClass("helper-box-compressed");
      $(reference).children().toggleClass("ui-icon-plusthick ui-icon-minusthick")
}

$(document).ready(function() {

	 loadGraphData("/js/initialGraph_CLASSICAL_MUSIC.js");

    $("#usageHints div ul li").toggle(
       function (el) { toggleInfoBox("#usageHints", this);
    }, function(el) { toggleInfoBox("#usageHints", this);
    });

    $("#about-box div ul li").toggle(
       function (el) { toggleInfoBox("#about-box", this);
    }, function(el) { toggleInfoBox("#about-box", this);
    });
	
   $('#graph-selector-dropdown').change(function(ev) {
	   loadGraphData(ev.target[ev.target.selectedIndex].value);
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
	    
	    /*
	     * Zoom
	     */
	    function transform() {
	        var t = this.transform().invert();
	        $('body').data('currentZoomLevel', t.x);
	        vis.render();
	    }

	    //initial values for animation controls
	    $('body').data('currentZoomLevel', 1);
	    $('body').data('lastSliderIndex', 0);

	    nodesInCurrentFrame = initialGraph.nodes; 
	    linksInCurrentFrame = initialGraph.links;

	    var w = document.body.clientWidth,
	        h = document.body.clientHeight,
	        colors = pv.Colors.category10();

	    vis = new pv.Panel()
	        .width(w)
	        .height(h)
	        .fillStyle("#2F4D71")
	        .event("mousedown", pv.Behavior.pan())
	        .event("mousewheel", pv.Behavior.zoom(1))
	        .event("pan", transform)
	        .event("zoom", transform);

	    force = vis.add(pv.Layout.Force)
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
	            showLinkElement(node);
	            vis.render();
	         })
	        .event("click", function(node) {
	            console.debug(node.nodeName + " clicked");
	        })
	        .event("mousedown", pv.Behavior.drag())
	        .event("drag", force);


	    force.label.add(pv.Label)
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
	
		<div id="change-log" class="ui-base-box">
			<div id="LogInfo" class="control">Change-Log</div>
			<ul></ul>
		</div>
		<div id="usageHints" class="ui-base-box helper-box-compressed">
            <div class="control">Usage Hints:
            <ul class="ui-widget ui-helper-clearfix"  id="icons">
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
			 <ul class="ui-widget ui-helper-clearfix"  id="icons">
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
