
function initializeCompletePanel() {
	
	var panner = new pv.Behavior.pan().bound(1);
	var zoomer = new pv.Behavior.zoom(2).bound(1);
	
	var colors = pv.Colors.category10();
	
	   vis = new pv.Panel()
       .width(document.body.clientWidth)
       .height(document.body.clientHeight)
       .fillStyle("#2F4D71")
       .event("mousedown", panner)
       .event("mousewheel", zoomer)
       .event("pan", transform)
       //.transform(pv.Transform.identity.scale(3.5).translate(-750,-400)) required translation is resolution depended!
       .event("zoom", transform);

   force = vis.add(pv.Layout.Force)
       .nodes(initialGraph.nodes)
       .links(initialGraph.links);
       //.springConstant(0.05)
       //.chargeTheta(0.4)
       //.dragConstant(0.009)
       //.bound(true)
       //.chargeConstant(-100);

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
                   return colors(d.group);
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
                   fontSize = 25;
               }
               else if (node.linkDegree * 0.7 < 12) {
                   fontSize = 12;
               } else {
                   fontSize = node.linkDegree * 0.7;
               }

               return fontSize + "px sans-serif";
           })
       .text(function(node) {
               var zoomLevel = $('body').data('currentZoomLevel');
               if(zoomLevel < 0.18) {
            	   return node.nodeName;
               }
               return "";
           });

   force.reset();
   vis.render();
}
