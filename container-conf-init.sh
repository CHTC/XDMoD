#!/bin/bash

for file in $(cat /setup_config/config_files.txt); do cat $file | envsubst "$(cat /setup_config/config_vars.txt)" > $file; done