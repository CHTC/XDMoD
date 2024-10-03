#!/bin/bash

#php /usr/share/xdmod/tools/etl/etl_overseer.php -p htcss.htcss-ingest -d 'HTCSS_LOG_DIR=$HTCSS_LOG_DIR'
#php /usr/share/xdmod/tools/etl/etl_overseer.php -p ingest-organizations  -p ingest-resource-types -p xdmod.ingest-resources -a xdmod.staging-ingest-common.resource-specs -p xdmod.hpcdb-ingest-common -p xdmod.hpcdb-xdw-ingest-common
#php /usr/share/xdmod/tools/etl/etl_overseer.php -p htcss.htcss-aggregate --last-modified-start-date "$(date -I)"
#xdmod-build-filter-lists -r Jobs
#acl-config