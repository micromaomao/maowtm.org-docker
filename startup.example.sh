#!/bin/bash
docker run --network mw -v v-mw-mongo:/data/db -v v-mw-mongo-configdb:/data/configdb --name=mw-mongo -d --rm mongo:latest --noauth
docker run --network mw -v v-mw-elasticsearch:/usr/share/elasticsearch/data --name=mw-es -d --rm docker.elastic.co/elasticsearch/elasticsearch:6.3.0
docker run --network mw -p 127.0.0.1:80:80 -p 127.0.0.1:443:443 --rm --name mw-www -it --env=NODE_ENV=development i-mw-www bash
