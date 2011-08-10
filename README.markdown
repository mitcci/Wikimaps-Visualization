# Project Wikimaps-Visualization

## Main Use-Case
Read a JSON File that is produced by <https://github.com/mitcci/Wikimaps-Collector> and display the
animated graph using <vis.stanford.edu/protovis/>. In the long term the visualization part should
be ported to <http://mbostock.github.com/d3/>

## Howto-Run
Deploy the files to any webserver, no serverside frameworks are required. The JSON-Animation files
tend to become rather large and the usage of gzip (mod_deflate etc.) is highly recommended.

## Output
index.html displays the animation, edit the elements in the <select> list to update 
available animations

## Configuration
* The force based layout related configurations are maintained in the file "protovis-setup" (dir: "js")


## Initial Autor
Github-User: ret0