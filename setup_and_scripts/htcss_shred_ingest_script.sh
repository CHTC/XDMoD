#!/bin/bash

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>/xdmod-ingest-log-$(date +%FT%H_%M_%S).out 2>&1

cp $HTCSS_DATA_LOG_DIR/resource_specs.json /etc/xdmod/resource_specs.json && cp $HTCSS_DATA_LOG_DIR/resources.json /etc/xdmod/resources.json

php /usr/share/xdmod/tools/etl/etl_overseer.php -v debug -p ingest-organizations  -p ingest-resource-types -p xdmod.ingest-resources -a xdmod.staging-ingest-common.resource-specs -p xdmod.hpcdb-ingest-common -p xdmod.hpcdb-xdw-ingest-common && xdmod-htcss-ingestor --debug -d "$HTCSS_DATA_LOG_DIR$(date -I)" --last-modified-start-date "$(date -I -d '-1 day')"