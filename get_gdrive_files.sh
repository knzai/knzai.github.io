#!/bin/bash
set -e #since I call this from a GH Action better to always know if it'll fail

#===============================================================================
# HEADER
#===============================================================================
#% SYNOPSIS
#+    ${SCRIPT_NAME} [-egtuhv] <csvfile> #-h or --help for more details
#% 
#% DESCRIPTION
#%    Download google drive file exports, eg gdocs -> pdf
#%
#% ARGUMENTS
#%    $1 <csvfile>      Leave blank for noop (add -e for lib usage)
#%                      Row format: gdrive_file_id,mime_type,dest,min_size\n                 
#%
#% OPTIONS
#%    -e, --export      Export the functions for your own use
#%    -g, --gapi_url    Specify different endpoint of the google drive api
#%    -t, --tempfile    If you want to be particular about the tempfile
#%    -u, --user_agent  I don't think Google actually cares, but hey
#%
#%    -h, --help        Print this help
#%    -v, --version     Print script information
#%
#% CURL USAGE - if it gets popular rate limiting, but that's not a concern now
#%    CSVFILE=gdrive_files.csv && GGTEMP=$(mktemp -t get_gdrive_filesXXXXXXXXXX.sh)\
#%      && curl -s -L https://gist.github.com/knzai/75702a336a25646e6c0039f96d5732b9/raw\
#%      > $GGTEMP && bash $GGTEMP $CSVFILE && echo $GGTEMP && rm $GGTEMP
#% 
#% EXAMPLES
#%    # Standard usage
#%    ${SCRIPT_NAME} path/to/csv
#%
#%    # Do nothing except export functions for your own use
#%    ${SCRIPT_NAME} -e 
#%
#%    # Specify a different version of the google drive api
#%    ${SCRIPT_NAME} -g https://www.googleapis.com/drive/v3 path/to/csv
#%
#===============================================================================
#- IMPLEMENTATION
#-    version         ${SCRIPT_NAME} (knz.ai) 0.0.2
#-    author          Kenzi Connor
#-    copyright       Copyright (c) Public Domain
#-    license         Public Domain via Unlicense (see footer)
#-    site            knz.ai/ggdrive
#-    source          https://gist.github.com/knzai/75702a336a25646e6c0039f96d5732b9
#-
#===============================================================================
#  ATTRIBUTIONS
#     Template for this header parsing
#        Michel VONGVILAY (https://www.uxora.com)
#        https://www.uxora.com/unix/shell-script/18-shell-script-template
#
#===============================================================================
#  HISTORY
#     2024/07/10 : 0.0.1 : knzai : Script creation
#     2024/07/11 : 0.0.2 : knzai : Cleaned up, comment, add help and usage
# 
#===============================================================================
# END_OF_HEADER
#===============================================================================

#============================
#  USAGE AND HELP OUPUT
#============================
usage() { printf "Usage: "; scriptinfo usg ; }
usagefull() { scriptinfo ful ; }
scriptinfo() { headFilter="^#-"
  [[ "$1" = "usg" ]] && headFilter="^#+"
  [[ "$1" = "ful" ]] && headFilter="^#[%+]"
  [[ "$1" = "ver" ]] && headFilter="^#-"
  head -${SCRIPT_HEADSIZE:-99} ${0} | grep -e "${headFilter}" | sed -e "s/${headFilter}//g" -e "s/\${SCRIPT_NAME}/${SCRIPT_NAME}/g"; }
SCRIPT_NAME="$(basename ${0})" # scriptname without path

#============================
#  PARSE ARGUMENTS
#============================
die() { echo "$*" >&2; exit 2; }  # complain to STDERR and exit with error
needs_arg() { if [ -z "$OPTARG" ]; then die "No arg for --$OPT option"; fi; }
if [ $# -eq 0 ]; then
    usage
    exit 0
fi

#defaults
EXPORT=false
GAPI_URL='https://www.googleapis.com/drive/v2'
TEMPFILE='tempfile'
USER_AGENT='github.com/knzai'

while getopts eg:t:u:hv-: OPT; do
  # support long options: https://stackoverflow.com/a/28466267/519360
  if [ "$OPT" = "-" ]; then   # long option: reformulate OPT and OPTARG
    OPT="${OPTARG%%=*}"       # extract long option name
    OPTARG="${OPTARG#"$OPT"}" # extract long option argument (may be empty)
    OPTARG="${OPTARG#=}"      # if long option argument, remove assigning `=`
  fi
  case "$OPT" in
    e|export     )                     EXPORT=true ;;
    g|gapi_url   ) needs_arg;   GAPI_URL="$OPTARG" ;;
    t|tempfile   ) needs_arg;   TEMPFILE="$OPTARG" ;;
    u|user_agent ) needs_arg; USER_AGENT="$OPTARG" ;;

    h|help       ) usagefull;               exit 0 ;;
    v|version    ) scriptinfo;              exit 0 ;;
    \? )                                    exit 2 ;;
    *  )           die "Illegal option --$OPT"     ;;
  esac
done
shift $((OPTIND-1)) # remove parsed options and args from $@ list

#============================
#  ALIAS AND FUNCTIONS
#============================
get_gdrive_files() {
  oldifs=$IFS
  IFS=','
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

#============================
#  MAIN SCRIPT
#============================

if [ $# -ne 0 ]; then
  if [ ! -f $1 ]; then
    echo "$1 file not found"; exit 99;
  fi
  get_gdrive_files $1
elif ! $EXPORT; then
  echo 'Flags passed, but neither -e nor <csvfile> so a NOOP'
fi

if $EXPORT; then
  export -f get_gdrive_files
  export -f gdrive_export
  export -f replace_if_valid
fi


#===============================================================================
# FOOTER
#===============================================================================
# LICENSE: Public Domain via Unlicense
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>
#
#===============================================================================
# END_OF_FOOTER
#===============================================================================