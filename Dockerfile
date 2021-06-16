FROM openjdk:8
ARG ATLAS_VERSION=2.1.0
ARG ES_OLD_VERSION=5.6.4
ARG ES_NEW_VERSION=2.1.0

RUN apt update \
&& apt -y install maven patch \
&& cd /opt \
&& wget https://apache.mirror.colo-serv.net/atlas/${ATLAS_VERSION}/apache-atlas-${ATLAS_VERSION}-sources.tar.gz \
&& export MANAGE_LOCAL_HBASE=true \
&& export MANAGE_LOCAL_SOLR=false \
&& export MAVEN_OPTS="-Xms2g -Xmx2g" \
&& tar -xzvf apache-atlas-${ATLAS_VERSION}-sources.tar.gz \
&& cd apache-atlas-sources-${ATLAS_VERSION} \
&& mvn clean -DskipTests package -Pdist,embedded-hbase-solr

RUN mv /opt/apache-atlas-sources-${ATLAS_VERSION}/distro/target/apache-atlas-${ATLAS_VERSION}-server.tar.gz /opt \
&& cd /opt \
&& tar -xzvf apache-atlas-${ATLAS_VERSION}-server.tar.gz

RUN cd /opt \
&& rm apache-atlas-${ATLAS_VERSION}-server.tar.gz apache-atlas-${ATLAS_VERSION}-sources.tar.gz \
&& rm -rf apache-atlas-sources-${ATLAS_VERSION}

COPY atlas-application.properties.patch /opt/apache-atlas-${ATLAS_VERSION}/conf/
RUN cd /opt/apache-atlas-${ATLAS_VERSION}/conf \
&& patch -b -f < atlas-application.properties.patch

# not sure what is a better way, running this to unpack /opt/apache-atlas-${ATLAS_VERSION}/server/webapp/atlas/WEB-INF
RUN cd /opt/apache-atlas-${ATLAS_VERSION}/ && ./bin/atlas_start.py

RUN cd /opt/apache-atlas-${ATLAS_VERSION}/server/webapp/atlas/WEB-INF/lib/ && rm elasticsearch-rest-client-5.6.4.jar elasticsearch-rest-high-level-client-${ES_OLD_VERSION}.jar
RUN cd /opt/apache-atlas-${ATLAS_VERSION}/server/webapp/atlas/WEB-INF/lib/ && wget https://repo1.maven.org/maven2/org/elasticsearch/client/elasticsearch-rest-client/${ES_NEW_VERSION}/elasticsearch-rest-client-${ES_NEW_VERSION}.jar

COPY atlas_start.py.patch /opt/apache-atlas-${ATLAS_VERSION}/bin/
RUN cd /opt/apache-atlas-${ATLAS_VERSION}/bin/ \
&& patch -b -f < atlas_start.py.patch
