#!/bin/bash

# get git stuff
git update

# compress js files
cd src/main/webapp/js
for f in *.js ; do gzip -c "$f" > "$f.gz" ; done

# start webserver
cd ../../../..
mvn jetty:run