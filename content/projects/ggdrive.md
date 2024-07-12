+++
title = "Google Drive File exporter bash script"
description = "Parses a csv of files to export from Google Drive APIs"
aliases = ["/ggdrive"]
+++

- Language/Platform: bash
- Github Repository: [gist](https://gist.github.com/knzai/75702a336a25646e6c0039f96d5732b9)

Used for purposes such as grabbing the latest pdf version of a Google Doc automatically for use in a generated static site

```bash
./get_gdrive_files.sh -h

 SYNOPSIS
    GAPI_KEY=**** ggdrive.sh [-egtuhv] <csvfile> #-h or --help for more details
 
 DESCRIPTION
    #Download google drive file exports, eg gdocs -> pdf

 ARGUMENTS
    $1 <csvfile>      #Leave blank for noop (add -e for lib usage)
                      #Row format: gdrive_file_id,mime_type,dest,min_size\n                 

 OPTIONS
    -e, --export      #Export the functions for your own use
    -g, --gapi_url    #Specify different endpoint of the google drive api
    -t, --tempfile    #If you want to be particular about the tempfile
    -u, --user_agent  #I don't think Google actually cares, but hey

    -h, --help        #Print this help
    -v, --version     #Print script information

 #CURL USAGE - if it gets popular rate limiting, but that's not a concern now
    CSVFILE=gdrive_files.csv && GGTEMP=$(mktemp -t get_gdrive_filesXXXXXXXXXX.sh)\
      && curl -s -L https://gist.github.com/knzai/75702a336a25646e6c0039f96d5732b9/raw\
      > $GGTEMP && bash $GGTEMP $CSVFILE && echo $GGTEMP && rm $GGTEMP
```