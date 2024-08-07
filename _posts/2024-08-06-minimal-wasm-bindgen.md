---
layout: post
title: "Simpler direct handling of HTML file input in Rust wasm"
image: /assets/img/posts/minimal-wasm-bindgen.png
description: >
  Dropping Yew and just calling the wasm_bindgen exported function directly
categories: ["rust", "wasm"]
toot_id: 112919231724048267
---
Earlier I figured out how to get [HTML file input selectors being called from my Rust code](/posts/2024-07-20-wasm-file-form) using [yew](https://yew.rs/) but eventually the complexity of doing everything in essentially js translated to Rust grated on my sensibilities. I can handroll the basic HTML and Javascript easier (and maybe wrap stuff neatly in a WebComponent) and then call out to my Rust lib when I need it.

It turns out it was even simpler than I expected to just call the wasm exported Rust function directly with the data from a [Javascript FileReader](https://developer.mozilla.org/en-US/docs/Web/API/FileReader)

For context, here is the (elided) function I'm going to call.
```rust
#[wasm_bindgen]
pub fn png(data: &[u8]) -> String {
    let mut bytes: Vec<u8> = Vec::new();
    ...stuff
    format!("data:application/png;base64,{}", STANDARD.encode(bytes))
}
```

And here's how simple it is to actually call it. You can just pass the `FileReader#readAsArrayBuffer`'s returned results right into the function. This, of course, happens in a callback since it's by default aysnc parsing in js (there is a separate sync if you just must lock up the UI, but why). So it's simpler to just keep the async in JS in that case and skip over a lot of complexity on the Rust side. This is essentially what would be getting called in the end anyway, as you need to pass throught this JS API to get access to the file data, apparently.
```html
<!doctype html>
<html lang="en">
<head>
   <link data-trunk rel="css" href="./styles.css" />
   <link 
   data-trunk 
   rel="rust" href="../../Cargo.toml"
   data-bin="cega-webc" 
   data-cargo-no-default-features 
   data-cargo-features="webc"
   />
   <script>
      const fileReader = new FileReader();
      fileReader.onloadend = function() {
         var array = new Int8Array(fileReader.result);
         document.getElementById('preview').src = window.wasmBindings.png(array);
      }
      document.addEventListener("DOMContentLoaded", () => {
         const fileInput = document.getElementById('file-input');
         fileInput.addEventListener("change", e => fileReader.readAsArrayBuffer(fileInput.files[0]));
      });
</script>
</head>
<body>
   <h1>Process your CGA/EGAs</h1>
   <input id="file-input" multiple="false" type="file" accept=".bin,.cga,.ega,.cega" />
   <img id="preview" src="" />
</body>
</html>
```

Oh, and all this can be done so simply partly thanks to [Trunk](https://trunkrs.dev/), which is one of the best parts of the rust-wasm tech stack I started with.