FROM docker.elastic.co/elasticsearch/elasticsearch:5.4.0

WORKDIR /usr/share/elasticsearch

USER root

ADD entry.sh bin/entry.sh

RUN set -x \
    && chmod +x bin/entry.sh

USER elasticsearch

CMD ["/bin/bash", "bin/entry.sh"]
