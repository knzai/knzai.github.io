---
title: file-byte-reader.js
caption: WebComponent to parse a file input into a bytearray
description: >
  WebComponent for simpler parsing of a file selector input into a bytearray (like to use in wasm file processing)
date: 10 Aug 2024
image: 
  path: /assets/img/projects/file-byte-reader.png
links:
  - title: "perma"
    url: https://knz.ai/projects/file-byte-reader
  - title: gist
    url: https://gist.github.com/knzai/c297fdd13739e1a844e4001142183459
---

- Language/Platform: Javascript


```javascript
//attach a listener (to an `is` applied file selector) that will get the parsed byte array to use:
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