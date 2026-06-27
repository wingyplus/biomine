use biome_js_formatter::context::JsFormatOptions;
use biome_js_parser::JsParserOptions;
use biome_js_syntax::JsFileSource;
use rustler::{Binary, Env, NifResult, OwnedBinary};

rustler::atoms! {
    source_not_utf8
}

// TODO: support JS/TS format options.
#[rustler::nif]
fn format_js<'a>(env: Env<'a>, source: Binary<'a>) -> NifResult<Binary<'a>> {
    let file_source = JsFileSource::ts();
    let input = std::str::from_utf8(source.as_slice()).unwrap();
    let parsed = biome_js_parser::parse(input, file_source, JsParserOptions::default());
    // TODO: parser check.
    // if parsed.has_errors() {
    //     return Err(Error::Term(format!("{:?}", parsed.diagnostics())));
    // }
    let options = JsFormatOptions::new(file_source);
    let formatted = biome_js_formatter::format_node(options, &parsed.syntax())
        .unwrap()
        .print_with_indent(2)
        .unwrap();

    let output = formatted.as_code().as_bytes();

    let mut binary = OwnedBinary::new(output.len()).unwrap();
    binary.as_mut_slice().copy_from_slice(output);

    Ok(binary.release(env))
}

#[rustler::nif]
fn format_css<'a>(env: Env<'a>, source: Binary<'a>) -> NifResult<Binary<'a>> {
    let input: &[u8] = source.as_slice();

    let mut binary = OwnedBinary::new(input.len()).unwrap();
    binary.as_mut_slice().copy_from_slice(input);

    Ok(binary.release(env))
}

rustler::init!("Elixir.Biomine.Native");
