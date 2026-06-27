use rustler::{Binary, Env, NifResult, OwnedBinary};


#[rustler::nif]
fn format_js<'a>(env: Env<'a>, source: Binary<'a>) -> NifResult<Binary<'a>> {
    let input: &[u8] = source.as_slice();

    let mut binary = OwnedBinary::new(input.len()).unwrap();
    binary.as_mut_slice().copy_from_slice(input);

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
