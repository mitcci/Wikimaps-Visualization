/**
 * returns new collection, both collections concatenated
 */
function addNodes(existingNodes, newNodes) {
    return existingNodes.concat(newNodes);
}

/**
 * returns new collection, nodes that are in "toBeDeleted"
 * are removed
 */
function removeNodes(existingNodes, toBeDeleted) {
    var updatedList = [];
    for(oldNode in existingNodes) {
        if(findIndex(toBeDeleted, existingNodes[oldNode].nodeName) == -1) {
            updatedList.push(existingNodes[oldNode]);
        }
    }
    return updatedList;
}

/**
 * returns the index of an element in the collection, -1 if not found
 */
function findIndex(collection, character) {
    for(element in collection) {
        if(collection[element].nodeName == character) {
            return parseInt(element);
        }
    }
    return -1;
}

/**
 * Transfers a name based link list into a index based one
 */
function transferToIndex(nodelist, linklist) {
    for(element in linklist) {
        linkobject = linklist[element];
        linkobject.source = findIndex(nodelist, linkobject.source);
        linkobject.target = findIndex(nodelist, linkobject.target);
    }
    return linklist
}

function generateGraphForFrame(oldFrameIndex, newFrameIndex) {
    $("#change-log > ul").append(createLogEntry(frameInformation[newFrameIndex]));
	
	var delta = newFrameIndex - oldFrameIndex;
	console.debug(delta);

    if(oldFrameIndex < newFrameIndex) { //forward in time
		for(var i = 0; i < delta; i++) {
			setNewFrame(oldFrameIndex + i);
		}
	} else if(oldFrameIndex > newFrameIndex) { //backwards in time
	    for(var i = 0; i < Math.abs(delta); i++) {
	        console.debug("old index was: " + oldFrameIndex);
			setNewFrameREVERSE(oldFrameIndex - i);
		}
	}
	
}

/**
 * Updates the graph according to the frame index
 */
function setNewFrame(newFrameIndex) {
    if(newFrameIndex < 0) {
        console.log("Not doing forward")
        return;
    }
    console.debug("strange empyt with index: " + newFrameIndex);
	console.debug("Adding: ", this.frameInformation[newFrameIndex].add);
	//$("#change-log").add("li");
	console.debug("Deleting: ",this.frameInformation[newFrameIndex].del);
	
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
    if(newFrameIndex < 0) {
        console.log("Not doing reverse")
        return;
    }
    
    console.debug("reverse!")
	console.debug("Adding: ", this.frameInformation[newFrameIndex].del);
	//$("#change-log").add("li");
	console.debug("Deleting: ",this.frameInformation[newFrameIndex].add);
	
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

