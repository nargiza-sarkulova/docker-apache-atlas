FROM openjdk:8

RUN apt update \
    && apt -y install \
      maven \
    && cd /opt \
    && wget https://apache.mirror.colo-serv.net/atlas/2.1.0/apache-atlas-2.1.0-sources.tar.gz \
    && export MANAGE_LOCAL_HBASE=true \
    && export MANAGE_LOCAL_SOLR=false \
    && export MAVEN_OPTS="-Xms2g -Xmx2g" \
    && tar -xzvf apache-atlas-2.1.0-sources.tar.gz \
    && mvn clean -DskipTests package -Pdist,embedded-hbase-solr

RUN mv /opt/apache-atlas-sources-2.1.0/distro/target/apache-atlas-2.1.0-server.tar.gz /opt
RUN cd /opt && tar -xzvf apache-atlas-2.1.0-server.tar.gz

RUN cd /opt && rm apache-atlas-2.1.0-server.tar.gz apache-atlas-2.1.0-sources.tar.gz
RUN cd /opt && rm -rf apache-atlas-sources-2.1.0

# patch settings:
# comment out solr settings
# atlas.graph.index.search.backend=elasticsearch
# atlas.graph.index.search.hostname=elasticsearch:9200
# atlas.graph.index.search.elasticsearch.client-only=true

# RUN cd /opt/apache-atlas-2.1.0/server/webapp/atlas/WEB-INF/ && rm elasticsearch-rest-client-5.6.4.jar
# RUN cd /opt/apache-atlas-2.1.0/server/webapp/atlas/WEB-INF/ && wget https://repo1.maven.org/maven2/org/elasticsearch/client/elasticsearch-rest-client/7.2.1/elasticsearch-rest-client-7.2.1.jar

# patch atlast_start.py to not quit
