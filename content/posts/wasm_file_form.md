+++
title = "Handling FormData and file inputs in Rust Wasm"
description = "Pull requests and example usage of yew, gloo, and web-sys"
date = 2024-07-20
+++

I submitted some [pull requests for additional examples](https://github.com/knzai/yew/pulls) to the top level library I'm using for Rust Wasm, [yew](https://yew.rs/). Some of the underlying tech and libraries have advanced since most examples were created, and there wasn't a simple one for one of the more common use cases (using a form with multiple fields, including a file-input selector).

Given there's a lot of PRs outstanding and the their CI is a bit b0rked, I don't know hwo likely they'll get pulled in, so I should document here. Also, some of the answers apply to the underlying lbraries even if you aren't using yew and it took some digging through reddit, code, examples, and finally Discord to find the current simplest answers.

<!-- more --> 

### Simple form

The [primary access to form data](https://github.com/knzai/yew/pull/3/files) can be handled from [web-sys](https://crates.io/crates/web-sys) directly. I'm using yew to build the html and handle the context and events and everything, but the yew events map tp web-sys events, so 

```rust
use web_sys::{FormData, HtmlFormElement};
use yew::prelude::*;
...
Msg::Submit(event) => {
	event.prevent_default();
	let form: HtmlFormElement = event.target_unchecked_into();
	let form_data = FormData::new_with_form(&form).expect("form data");
	self.names.push(format!(
	    "{} {}",
	    form_data.get("first").as_string().unwrap(),
	    form_data.get("last").as_string().unwrap()
));
...
//yes this is still actually a rust file, not html. Yew does some funky with a macro for handling inline html nodes
html! {
	<form onsubmit={ctx.link().callback(Msg::Submit)}>
	    <label>{"Sign up"}</label>
	    <input name="first" placeholder="First name"/>
	    <input name="last" placeholder="Last name"/>
	    <input type="submit"/>
	</form>
```

To keep things snappy, makes heavy use of features/conditional compilation, so make sure to include the ones you need.
```toml
[dependencies.web-sys]
version = "0.3.69"
features = ["FormData", "HtmlFormElement"]
```

### Form with file input selector and callbacks

Handling [file data from an input in form](https://github.com/knzai/yew/pull/2/files) gets a bit more complicated on the client side. Te browser just stores a reference to the file in that input, so you don't just get immediate access to it. To actually parse the file data requires starting to deal with more async bridging between [rust, js, and native browser bindings](https://rustwasm.github.io/wasm-bindgen/introduction.html).

At it's core it's still relatively simple, once you understand it and have pared all the fluff off (the original upload examples handles drag and drop, which is nice for UX, but gets in the way when going for a simplest base case)

In the form we make a callback for the actual submission, and make another one on the file input directly, so it can kick-off the file parsing immediately and not wait for clicking submit. I actually disable the submit button till that is finished, to simplify the async handling. gloo, well does what it's named for, and sticks a lot of the js_sys and web_sys together in a way that makes it easy for yew (ha!) to deal with. In particular `gloo::file::FileList::from` handles the unwrapped and conversions to get a simple FileList type from the binding of the input, which we can then pass along to our file handling.
```rust
use std::collections::HashMap;

use base64::{engine::general_purpose::STANDARD, Engine};
use gloo::file::{callbacks::FileReader, File, FileList};
use gloo_console::debug;
use web_sys::{File as RawFile, FormData, HtmlFormElement, HtmlInputElement};
use yew::prelude::*;
...
html! {
<form onsubmit={ctx.link().callback(Msg::Submit)}>
    <lable for="alt-text">{"Alt Text"}</lable>
    <input id="alt-text" name="alt-text" />
    <input
        id="file"
        name="file"
        type="file"
        accept="image/*"
        multiple={false}
        onchange={ctx.link().callback(move |e: Event| {
            let input: HtmlInputElement = e.target_unchecked_into();
            Msg::File(gloo::file::FileList::from(input.files().expect("file")))
            })}
    />
```

This is the core of the tricky bits. Again gloo streamlines a lot and `gloo::file::callbacks::read_as_bytes` handles the async parsing of the file data itself out of the file list. Since this is async and hands back a FileReader, we have to stick that reader somewhere to keep it alive and going, and a hashmap keyed off the filename works fine. When this completes we store the file_data in app state directly as a Vec<byte> rather than adding more complex transforms back and forth across the bindgens, reenable submit and unref the reader closure from our hashmap.

```rust
Msg::Loaded(name, data) => {
    let submit = self.button.cast::<HtmlInputElement>().expect("button");
    self.file_data = data;
    submit.set_disabled(false);
    self.readers.remove(&name);
}
Msg::File(files) => {
    let submit = self.button.cast::<HtmlInputElement>().expect("button");
    submit.set_disabled(true);

    let file = files[0].clone();
    let link = ctx.link().clone();
    let name = file.name().clone();
    let task = {
        gloo::file::callbacks::read_as_bytes(&file, move |res| {
            link.send_message(Msg::Loaded(name, res.expect("failed to read file")));
        })
    };
    self.readers.insert(file.name(), task);
}
```

After that our submit logic is mostly just form handling + grabbing our stored file data out of state (resetting that might be unneccessary since it'll just overwrite, but it just seems cleaner, just in case). `self.files` is just a Vec<FileDetails> we use to iterate over and output the files. Oh maybe that's also interesting, I'll include that part, but it's just standard approach to writing base64 mage data directly into the src attribute.

```rust
Msg::Submit(event) => {
    debug!(event.clone()); // gloo_console for nice debugging via the browser inspector console
    event.prevent_default();
    let form: HtmlFormElement = event.target_unchecked_into();
    let form_data = FormData::new_with_form(&form).expect("form data");
    let image_file = File::from(RawFile::from(form_data.get("file")));

    let alt_text = form_data.get("alt-text").as_string().unwrap();
    let name = image_file.name();
    let data = self.file_data.clone();

    let file_type = image_file.raw_mime_type();
    self.files.push(FileDetails {
        alt_text,
        name,
        data,
        file_type,
    });
    self.file_data = Vec::default();
}
fn view_file(file: &FileDetails) -> Html {
    let src = format!(
        "data:{};base64,{}",
        file.file_type,
        STANDARD.encode(&file.data)
    );
    html! {
        <div class="preview-tile">
            <p class="preview-name">{ format!("{}", file.name) }</p>
            <div class="preview-media">
                <img src={src} alt={file.alt_text.clone()}/>
            </div>
        </div>
    }
}

```