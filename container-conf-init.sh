#!/bin/bash

SERVER_MEM_BYTES=$(($MYSQL_SERVER_MEM_GIGS * 1024 * 1024 * 1024))
export MYSQL_BUFFER_POOL_SIZE=$(($SERVER_MEM_BYTES / 2))
export MYSQL_LOG_FILE_SIZE=$(($MYSQL_BUFFER_POOL_SIZE / 4))

for file in $(cat /setup_config/config_files.txt); do cat $file | envsubst "$(cat /setup_config/config_vars.txt)" > $file; done