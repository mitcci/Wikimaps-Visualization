/**
 * returns new collection, both collections concatenated
 */
function addNodes(existingNodes, newNodes) {
    return existingNodes.concat(newNodes);
}

/**
 * returns new collection, nodes that are in "toBeDeleted" are removed
 */
function removeNodes(existingNodes, toBeDeleted) {
    var updatedList = [];
    for (oldNode in existingNodes) {
        if (findIndex(toBeDeleted, existingNodes[oldNode].nodeName) == -1) {
            updatedList.push(existingNodes[oldNode]);
        }
    }
    return updatedList;
}

/**
 * returns the index of an element in the collection, -1 if not found
 */
function findIndex(collection, character) {
    for (element in collection) {
        if (collection[element].nodeName == character) {
            return parseInt(element);
        }
    }
    return -1;
}

/**
 * Transfers a name based link list into a index based one
 */
function transferToIndex(nodelist, linklist) {
    for (element in linklist) {
        linkobject = linklist[element];
        linkobject.source = findIndex(nodelist, linkobject.source);
        linkobject.target = findIndex(nodelist, linkobject.target);
    }
    return linklist
}

function generateGraphForFrame(oldFrameIndex, newFrameIndex) {
	var index = newFrameIndex - 1;
	if(index < 0) {
		//$("#change-log > ul").append(createLogEntry(initialGraph));
	} else {
		$("#change-log > ul").append(createLogEntry(frameInformation[index]));
	}

    var delta = newFrameIndex - oldFrameIndex;
    console.debug(delta);

    if (oldFrameIndex < newFrameIndex) { // forward in time
        for (var i = 0; i < delta; i++) {
            setNewFrame(oldFrameIndex + i);
        }
    } else if (oldFrameIndex > newFrameIndex) { // backwards in time
        for (var i = 1; i < Math.abs(delta); i++) {
            console.debug("old index was: " + oldFrameIndex);
            setNewFrameREVERSE(oldFrameIndex - i);
        }
    }

}

/**
 * Updates the graph according to the frame index
 */
function setNewFrame(newFrameIndex) {
    if (newFrameIndex < 0) {
        console.log("Not doing forward")
        return;
    }
    console.debug("strange empyt with index: " + newFrameIndex);
    console.debug("Adding: ", this.frameInformation[newFrameIndex].add);
    console.debug("Deleting: ", this.frameInformation[newFrameIndex].del);

    var updatedList = addNodes(nodesInCurrentFrame, this.frameInformation[newFrameIndex].add);
    updatedList = removeNodes(updatedList, this.frameInformation[newFrameIndex].del);
    var updatedLinks = transferToIndex(updatedList, this.frameInformation[newFrameIndex].links);

    this.nodesInCurrentFrame = updatedList;
    this.linksInCurrentFrame = updatedLinks;
    force.nodes(updatedList);
    force.links(updatedLinks);
    force.reset();
    vis.render();
}

function setNewFrameREVERSE(newFrameIndex) {
    if (newFrameIndex < 0) {
        console.log("Not doing reverse")
        return;
    }

    console.debug("reverse!")
    console.debug("Adding: ", this.frameInformation[newFrameIndex].del);
    console.debug("Deleting: ", this.frameInformation[newFrameIndex].add);

    var updatedList = addNodes(nodesInCurrentFrame, this.frameInformation[newFrameIndex].del);
    updatedList = removeNodes(updatedList, this.frameInformation[newFrameIndex].add);
    var updatedLinks = transferToIndex(updatedList, this.frameInformation[newFrameIndex].links);

    this.nodesInCurrentFrame = updatedList;
    this.linksInCurrentFrame = updatedLinks;
    force.nodes(updatedList);
    force.links(updatedLinks);
    force.reset();
    vis.render();
}

function showLinkElement(node) {
    $("#additionalNodeInfo div").html("Read more about <a href=\"http://en.wikipedia.org/wiki/" + node.nodeName + "\" target=\"_blank\">" + node.nodeName + " on Wikipedia</a>");
}

function loadGraphData(jsonURL) {
    $.ajax({
        type: "GET",
        url: jsonURL,
        async: false,
        mimeType: 'application/json',
        success: function (data) {
            initialGraph = data.initialGraph;
            frameInformation = data.frameInformation;
            nodesInCurrentFrame = initialGraph.nodes;
            linksInCurrentFrame = initialGraph.links;
            $("#change-log > ul").empty();
            force.nodes(initialGraph.nodes);
            force.links(initialGraph.links);
            this.frameInformation = data.frameInformation;
            $("#frameInfo").text("Date: " + initialGraph.date);
            $("#slider").slider("option", "value", 0);
            $('body').data('lastSliderIndex', 0);
            stopAnimation();
            
            /* Initialize positions randomly near the center. */ 
            for (var i = 0, n; i < force.nodes().length; i++) { 
              n = force.nodes()[i]; 
              if (isNaN(n.x)) n.x = w / 2 + 40 * Math.random() - 20; 
              if (isNaN(n.y)) n.y = h / 2 + 40 * Math.random() - 20; 
            } 
            
            force.reset();
            force.render();
            vis.render();
        }
    });
}

function stopAnimation() {
    $("#slider").css("background", "");
    for (index in currentTimeouts) {
        clearTimeout(currentTimeouts[index]);
    }
}

/**
 * @param nodeList
 * @returns String containing a comma separated list of nodenames
 */
function printNodeNameList(nodeList) {
    if (nodeList.length == 0) {
        return "-";
    } else {
        return jQuery.map(nodeList, function (n, i) {
            return (n.nodeName);
        }).join(", ");
    }
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

// code based on
// http://groups.google.com/group/protovis/browse_thread/thread/688d17dbc32360e8
function zoom(type_zoom) {

    var zoom_ratio = 0.5;
    var x0 = vis.transform().x;
    var y0 = vis.transform().y;
    var k0 = vis.transform().k;
    var w = vis.width();
    var h = vis.height();
    
    //$('body').data('currentZoomLevel', x0);

    // calculate the original values I submitted (the values before and after the rendering are different)
    var x0_submitted = (x0 / k0)
    var x0_central = ((w / k0) - w) / 2;
    var delta_x0 = x0_submitted - x0_central;
    var y0_submitted = (y0 / k0)
    var y0_central = ((h / k0) - h) / 2;
    var delta_y0 = y0_submitted - y0_central;

    // calculate the zoom that cannot be less then 1
    if (type_zoom == 'in') {
        var k1 = k0 + zoom_ratio;
    } else {
        if ((k0 > 1) && ((k0 - zoom_ratio) > 1)) var k1 = k0 - zoom_ratio;
        else var k1 = 1;
    }
    //calculate the delta between the zoom in the center and the actual zoom (the pan)
    var delta_x1 = Math.round((delta_x0 * k1) / k0);
    var delta_y1 = Math.round((delta_y0 * k1) / k0);
    // final values
    var x1 = ((w / k1) - w) / 2 + delta_x1;
    var y1 = ((h / k1) - h) / 2 + delta_y1;
    // actual transformation
    vis.transform(pv.Transform.identity.scale(k1).translate(x1, y1));
    vis.render();
}

function toggleInfoBox(elementID, reference) {
    $(reference).parents(elementID).toggleClass("helper-box-compressed");
    $(reference).children().toggleClass("ui-icon-plusthick ui-icon-minusthick");
}

function attachEventHandlers() {

    $("#usageHints div ul li").toggle(

    function (el) {
        toggleInfoBox("#usageHints", this);
    }, function (el) {
        toggleInfoBox("#usageHints", this);
    });

    $("#about-box div ul li").toggle(

    function (el) {
        toggleInfoBox("#about-box", this);
    }, function (el) {
        toggleInfoBox("#about-box", this);
    });

    $('#graph-selector-dropdown').change(function (ev) {
        loadGraphData(ev.target[ev.target.selectedIndex].value);
    });

    $("#ui-icon-zoomin").click(function (ev) {
        zoom("in");
        var t = vis.transform().invert();
        $('body').data('currentZoomLevel', t.k);
    });
    
    $("#ui-icon-zoomout").click(function (ev) {
        zoom("out");
        var t = vis.transform().invert();
        $('body').data('currentZoomLevel', t.k);
    });
    
    //hover states on the static widgets
    $('#dialog_link, ul#icons li').hover(

    function () {
        $(this).addClass('ui-state-hover');
    }, function () {
        $(this).removeClass('ui-state-hover');
    });

    $("#frameInfo").text("Date: " + initialGraph.date);

    $("#slider").slider({
        max: frameInformation.length - 1,
        animate: true,
        change: function (event, ui) {
            if (event.button == 0) {
                stopAnimation();
                slideChange(ui.value, false);
            }
        },
        slide: function(event, ui) {
        	stopAnimation();
            slideChange(ui.value, false);
        }
    });

    $("#play").click(function () {
        var delta = 1800;
        var counter = 1;
        $("#slider").css("background", "#A0C575");
        for (var index = $('body').data('lastSliderIndex'); index < frameInformation.length; index++) {
            (function (index) {
                if (counter == 1) {
                    currentTimeouts.push(setTimeout(function () {
                        slideChange(index, true);
                    }, counter));
                } else {
                    currentTimeouts.push(setTimeout(function () {
                        slideChange(index, true);
                    }, delta * counter));
                }
                counter = counter + 1;
            })(index);
        }
    });

    $("#pause").click(stopAnimation);
}

/**
 * Zoom, stores current level, determined by mouse transformation
 * this enables the display of text labels at the desired zoom levels
 */
function transform() {
    var t = this.transform().invert();
    $('body').data('currentZoomLevel', t.k);
    vis.render();
}

function stopAnimation() {
    $("#slider").css("background", "");
    for (index in currentTimeouts) {
        clearTimeout(currentTimeouts[index]);
    }
}

function slideChange(index, updateSlider) {
    if (updateSlider) {
        $("#slider").slider("option", "value", index);
    }
    var newFrameIndex = index;
    var oldFrameIndex = $('body').data('lastSliderIndex');
    if(newFrameIndex != oldFrameIndex) {
    	$('body').data('lastSliderIndex', newFrameIndex);
    	generateGraphForFrame(oldFrameIndex, newFrameIndex);
    	if(newFrameIndex - 1 >= 0) {
    		$("#frameInfo").text("Date: " + frameInformation[newFrameIndex - 1].date);
    	}
    	$("#change-log").scrollTop(8000);
    }
}