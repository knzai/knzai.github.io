---
layout: post
title: Exporting a Google Doc into a PDF in a Github Action
description: >
  Basically just a wget call
redirect_from:
  - /posts/gdoc-pdf-export/
---
ETA: this, of course, I then rolled into a [bash script with way too nice of usage()\* for a few-liner](/projects/ggdrive.md).  [\*bash convention for the help function]

It turns out that grabbing the current pdf export of my resume during zola build was even easier than [cleaning the Google HTML](/blog/example/2024-07-06-cleaning-gdocs/). Once you've setup the Google API keys it's basically one wget (which is already installed on their ubuntu runner) call.

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