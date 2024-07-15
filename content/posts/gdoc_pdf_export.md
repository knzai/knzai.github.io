+++
title = "Exporting a Google Doc into a PDF in a Github Action"
description = "Basically just a wget call"
date = 2024-07-09
+++
It turns out that grabbing the current pdf export of my resume during zola build was even easier than [cleaning the Google HTML](@/posts/cleaning_gdocs.md). Once you've setup the Google API keys it's basically one wget (which is already installed on their ubuntu runner) call.

{{header_image()}}