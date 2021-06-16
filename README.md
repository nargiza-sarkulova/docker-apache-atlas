# docker-apache-atlas
Apache Atlas built with embedded HBase and external Elasticsearch. 

To run:
```
docker compose up -d
```

At the first startup it'll setup HBase tables and Elasticsearch indexes.

To tail logs:
```
docker exec -ti atlas tail -f /opt/apache-atlas-2.1.0/logs/application.log
```

Atlas UI: http://localhost:21000/ (admin:admin)
