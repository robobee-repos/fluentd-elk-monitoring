#!/bin/bash
set -xe

cp /config.in/elasticsearch.yml /usr/share/elasticsearch/config/
cp /config.in/log4j2.properties /usr/share/elasticsearch/config/

exec bin/es-docker "$@"
