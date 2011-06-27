#!/bin/bash

# making sure mvn is alright
export PATH=/home/ec2-user/apache-maven-3.0.3/bin::$PATH

# get git stuff
git pull

# compress js files
cd src/main/webapp/js
for f in *.js ; do gzip -c "$f" > "$f.gz" ; done

# start webserver
cd ../../../..
mvn jetty:run&