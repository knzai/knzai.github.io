#!/bin/bash
set -e

############################################################
# Filename   : fetch_gdrive.sh                             #
# Author     : Kenzi Connor: https://knz.ai                #
# Created    : 2024-07-11                                  #
# Purpose    : Download google drive file exports          #
# Arguments  : and defaults v---v                          #
input_csv=${1:-gdrive_files.csv}                           #
GAPI_URL=${2:-'https://www.googleapis.com/drive/v2'}       #
TEMPFILE=${3:-'tempfile'}                                  #
USER_AGENT=${4:-'github.com/knzai'}                        #
# input_csv  : gdrive_file_id,mime_type,dest,min_size\n    #
############################################################

# GNU All-Permissive License {{{
#############################################################
# Copyright © 2022 my_name                                  #
#                                                           #
# Copying and distribution of this file, with or without    #
# modification, are permitted in any medium without         #
# royalty, provided the copyright notice and this notice    #
# are preserved.                                            #
#                                                           #
# This file is offered as-is, without any warranty.         #
#############################################################
# End license }}}

main() {
  oldifs=$IFS
  IFS=','
  [ ! -f $1 ] && { echo "$1 file not found"; exit 99; }
  while read gd_id mime dest min_size
  do
    gdrive_export $gd_id $mime
    replace_if_valid $dest $min_size
  done < $1
  IFS=$oldifs
}
gdrive_export() {
  #$1: google_file_id
  #$2: mime_type
  wget -O $TEMPFILE --user-agent=$USER_AGENT "$GAPI_URL/files/$1/export?mimeType=$2&key=$GAPI_KEY"
}
replace_if_valid() {
  #$1: dest
  #$2: min_size
  if [ $(du -k $TEMPFILE | cut -f1) -gt $2 ]; then
    mv $TEMPFILE "$1"
  else
    echo "Problem fetching file"
    exit 1
  fi
}

main $input_csv
