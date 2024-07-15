+++
title = "ggdrive.sh"
description = "Bash script to export files from Google Drive, eg gdoc -> pdf"
aliases = ["/ggdrive"]
+++

- Language/Platform: bash
- Github Repository: [gist](https://gist.github.com/knzai/75702a336a25646e6c0039f96d5732b9)

Used for purposes such as grabbing the latest pdf version of a Google Doc automatically for use in a generated static site

{{header_image()}}

```bash
Name: ggdrive.sh (1.2.0)
Description: Download google drive file exports, eg gdocs -> pdf
Usage: 
<G_API_KEY=XXXX> ./ggdrive.sh [-h, --help] [-v] [-e] [-g <g_api>] [-t <tempfile>] [-u <user_agent>] [csv_file]

Environoment variables:
   G_API_KEY           REQUIRED Google Cloud API Key with access to Google Drive API

Arguments:
   [csv_file]          Path/to/file.csv. Leave blank for NOOP.

Flags:
   [-e, --export]      Export functions. Use w/o [csv_file] for custom handling
   [-v, --version]     Output version info. Long form provides more metadata
   [-h, --help]        Output help. Long form provides more info, examples

Options
   #Specify endpoint of the google drive api
   [-g, --g_api] <arg> {'https://www.googleapis.com/drive/v2'}

   #If you want to be particular about the temporary file              
   [-t, --tempfile] <arg> {tempfile}

   #I don't think Google actually cares, but hey
   [-u, --user_agent] <arg> {'gist.github.com/knzai/75702a336a25646e6c0039f96d5732b9'}
```