+++
title = "Exporting a Google Doc into a PDF in a Github Action"
description = "Basically just a wget call"
date = 2024-07-09
+++

ETA: this, of course, I then rolled into a [bash script with way to nice of usage() and help for a few-liner](@/projects/ggdrive.md)

It turns out that grabbing the current pdf export of my resume during zola build was even easier than [cleaning the Google HTML](@/posts/cleaning_gdocs.md). Once you've setup the Google API keys it's basically one wget (which is already installed on their ubuntu runner) call.

{{header_image()}}

```yml
- name: download pdf
  shell: bash
  run: "wget -O 'tmp.pdf' --user-agent='github.com/knzai' \
    'https://www.googleapis.com/drive/v2/files/${{vars.GOOGLE_FILE_ID}}\
    /export?mimeType=application/pdf&key=${{secrets.GOOGLE_API_KEY}}'"
- name: replace pdf with newer, if valid (over 30k)
  shell: bash
  run: |
    if [ $(du -k 'tmp.pdf' | cut -f1) -gt 30 ]; then
      mv tmp.pdf static/assets/Kenzi\ Connor\ Resume.pdf
    else
      exit 1
    fi
```