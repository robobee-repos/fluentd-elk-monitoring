FROM docker.elastic.co/elasticsearch/elasticsearch:5.4.0

USER root

ADD entry.sh /

RUN set -x \
    && chmod +x /entry.sh

USER elasticsearch

WORKDIR /usr/share/elasticsearch

RUN set -x \
    && elasticsearch-plugin remove x-pack

ENTRYPOINT ["/entry.sh"]

CMD ["/bin/bash", "bin/es-docker"]
