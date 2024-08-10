---
layout: post
title: "Minimal WebComponent to parse file selectors into bytearrays"
image: /assets/img/projects/file-byte-reader.png
description: >
  Extending the HTMLInputElement and using custom events for easy hooks
toot_id: 112938841131588752
---

I'm in the process of moving the (non-wasm parts) of my web front-end for [cega](/projects/cega) over to vanilla Jasvacript WebComponents. I've liked how much it cleans up and encapsulates the logic without even needing a framework. The hooks for parsing the file into a byte array on the client-side (for passing to the wasm) were an obvious extraction point, so I pulled it out to a gist micro-project: [file-byte-reader](/projects/file-byte-reader).

This hides a [lower-level abstraction with its own async, FileReader](https://developer.mozilla.org/en-US/docs/Web/API/FileReader). It also makes a nice real world example of extending an input tag and using custom events to give easy hooks for your WebComponents.  I liked the [pattern Chris Ferdinandi was using for having a (partially) curried emit function to make dispatching your events more succinct](https://gomakethings.com/custom-events-in-web-components/), so I've added it to my practices for WebComponents going forward.

ETA: The code in this post may not get updates, so check the gist on the [project page](/projects/file-byte-reader) for the latest.

```javascript
//attach a listener (to an `is` applied file selector) that will get the parsed byte array:
//<input is="file-byte-reader" id="file-input" type="file"
//$('#file-input').addEventListener("file-byte-reader:loaded", e => YOURHANDLER(e.detail));
class FileByteReader extends HTMLInputElement {
  connectedCallback() {
    this.addEventListener('change', this.onChange);
  }

  emit (type, detail = {}) {
    let event = new CustomEvent(`file-byte-reader:${type}`, {
      bubbles: false,
      cancelable: false,
      detail: detail
    });
    return this.dispatchEvent(event);
  }

  onFileLoad(event) {
    this.emit('loaded', new Int8Array(event.target.result));
  }

  onChange() {
    if (this.files.length == 0) { return }
    Array.from(this.files).forEach(file => {
      const fileReader = new FileReader();
      fileReader.addEventListener('loadend', e => this.onFileLoad(e));
      fileReader.readAsArrayBuffer(file);
    });
  }
}
customElements.define("file-byte-reader", FileByteReader, { extends: 'input'});
```