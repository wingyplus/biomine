use biome_css_formatter::context::CssFormatOptions;
use biome_css_parser::CssParserOptions;
use biome_diagnostics::{Diagnostic, PrintDescription};
use biome_formatter::{
    AttributePosition, BracketSameLine, BracketSpacing, IndentStyle, IndentWidth, LineEnding,
    LineWidth, QuoteStyle,
};
use biome_js_formatter::context::JsFormatOptions;
use biome_js_formatter::context::{ArrowParentheses, QuoteProperties, Semicolons, TrailingCommas};
use biome_js_parser::JsParserOptions;
use biome_languages::{CssFileSource, JsFileSource};
use rustler::{Atom, Binary, Encoder, Env, OwnedBinary, Term};

mod atoms {
    rustler::atoms! {
        ok,
        error,
        parse_error,
        invalid_option,
        message,
        span,
        start,
        end,
        indent_style,
        indent_width,
        line_ending,
        line_width,
        quote_style,
        jsx_quote_style,
        quote_properties,
        trailing_comma,
        semicolons,
        arrow_parentheses,
        bracket_spacing,
        bracket_same_line,
        attribute_position,
        tab,
        space,
        lf,
        crlf,
        cr,
        double,
        single,
        as_needed,
        preserve,
        all,
        es5,
        none,
        always,
        auto,
        multiline,
        tailwind_directives
    }
}

fn ok<T>(term: T) -> (Atom, T) {
    (atoms::ok(), term)
}

fn error<T>(term: T) -> (Atom, T) {
    (atoms::error(), term)
}

#[rustler::nif]
fn format_js<'a>(
    env: Env<'a>,
    source: Binary<'a>,
    options: Vec<(Atom, Term<'a>)>,
) -> (Atom, Term<'a>) {
    let file_source = JsFileSource::ts();
    let input = std::str::from_utf8(source.as_slice()).unwrap();
    let parsed = biome_js_parser::parse(input, file_source, JsParserOptions::default());
    if parsed.has_errors() {
        return error(parse_error(env, parsed.diagnostics()));
    }
    let js_options = match override_js_options(JsFormatOptions::new(file_source), options) {
        Ok(options) => options,
        Err(reason) => return error(reason.to_term(env)),
    };

    let formatted = biome_js_formatter::format_node(js_options, &parsed.syntax(), Vec::new())
        .unwrap()
        .print()
        .unwrap();

    let output = formatted.as_code().as_bytes();

    let mut binary = OwnedBinary::new(output.len()).unwrap();
    binary.as_mut_slice().copy_from_slice(output);

    ok(binary.release(env).to_term(env))
}

fn parse_error<'a>(
    env: Env<'a>,
    diagnostics: &[biome_parser::diagnostic::ParseDiagnostic],
) -> Term<'a> {
    let diagnostics = diagnostics
        .iter()
        .map(|diagnostic| parse_diagnostic(env, diagnostic))
        .collect::<Vec<_>>();

    (atoms::parse_error(), diagnostics).encode(env)
}

fn parse_diagnostic<'a>(
    env: Env<'a>,
    diagnostic: &biome_parser::diagnostic::ParseDiagnostic,
) -> Term<'a> {
    let mut keys = vec![atoms::message().to_term(env)];
    let mut values = vec![format!("{}", PrintDescription(diagnostic)).encode(env)];

    if let Some(span) = diagnostic.location().span {
        keys.push(atoms::span().to_term(env));
        values.push(parse_span(env, span));
    }

    Term::map_from_term_arrays(env, &keys, &values).unwrap()
}

fn parse_span<'a>(env: Env<'a>, span: biome_rowan::TextRange) -> Term<'a> {
    let keys = [atoms::start().to_term(env), atoms::end().to_term(env)];
    let values = [
        u32::from(span.start()).encode(env),
        u32::from(span.end()).encode(env),
    ];

    Term::map_from_term_arrays(env, &keys, &values).unwrap()
}

fn override_js_options(
    mut format_options: JsFormatOptions,
    options: Vec<(Atom, Term)>,
) -> Result<JsFormatOptions, Atom> {
    for (key, value) in options {
        match key {
            key if key == atoms::indent_style() => {
                format_options.set_indent_style(decode_indent_style(value)?);
            }
            key if key == atoms::indent_width() => {
                format_options.set_indent_width(
                    IndentWidth::try_from(decode_u8(value)?)
                        .map_err(|_| atoms::invalid_option())?,
                );
            }
            key if key == atoms::line_ending() => {
                format_options.set_line_ending(decode_line_ending(value)?);
            }
            key if key == atoms::line_width() => {
                let line_width =
                    LineWidth::try_from(decode_u16(value)?).map_err(|_| atoms::invalid_option())?;
                format_options.set_line_width(line_width);
            }
            key if key == atoms::quote_style() => {
                format_options.set_quote_style(decode_quote_style(value)?);
            }
            key if key == atoms::jsx_quote_style() => {
                format_options.set_jsx_quote_style(decode_quote_style(value)?);
            }
            key if key == atoms::quote_properties() => {
                format_options.set_quote_properties(decode_quote_properties(value)?);
            }
            key if key == atoms::trailing_comma() => {
                format_options.set_trailing_commas(decode_trailing_comma(value)?);
            }
            key if key == atoms::semicolons() => {
                format_options.set_semicolons(decode_semicolons(value)?);
            }
            key if key == atoms::arrow_parentheses() => {
                format_options.set_arrow_parentheses(decode_arrow_parentheses(value)?);
            }
            key if key == atoms::bracket_spacing() => {
                format_options.set_bracket_spacing(BracketSpacing::from(decode_bool(value)?));
            }
            key if key == atoms::bracket_same_line() => {
                format_options.set_bracket_same_line(BracketSameLine::from(decode_bool(value)?));
            }
            key if key == atoms::attribute_position() => {
                format_options.set_attribute_position(decode_attribute_position(value)?);
            }
            _ => return Err(atoms::invalid_option()),
        }
    }

    Ok(format_options)
}

fn decode_atom(term: Term) -> Result<Atom, Atom> {
    term.decode::<Atom>().map_err(|_| atoms::invalid_option())
}

fn decode_bool(term: Term) -> Result<bool, Atom> {
    term.decode::<bool>().map_err(|_| atoms::invalid_option())
}

fn decode_u8(term: Term) -> Result<u8, Atom> {
    term.decode::<u8>().map_err(|_| atoms::invalid_option())
}

fn decode_u16(term: Term) -> Result<u16, Atom> {
    term.decode::<u16>().map_err(|_| atoms::invalid_option())
}

fn decode_indent_style(term: Term) -> Result<IndentStyle, Atom> {
    match decode_atom(term)? {
        atom if atom == atoms::tab() => Ok(IndentStyle::Tab),
        atom if atom == atoms::space() => Ok(IndentStyle::Space),
        _ => Err(atoms::invalid_option()),
    }
}

fn decode_line_ending(term: Term) -> Result<LineEnding, Atom> {
    match decode_atom(term)? {
        atom if atom == atoms::lf() => Ok(LineEnding::Lf),
        atom if atom == atoms::crlf() => Ok(LineEnding::Crlf),
        atom if atom == atoms::cr() => Ok(LineEnding::Cr),
        _ => Err(atoms::invalid_option()),
    }
}

fn decode_quote_style(term: Term) -> Result<QuoteStyle, Atom> {
    match decode_atom(term)? {
        atom if atom == atoms::double() => Ok(QuoteStyle::Double),
        atom if atom == atoms::single() => Ok(QuoteStyle::Single),
        _ => Err(atoms::invalid_option()),
    }
}

fn decode_quote_properties(term: Term) -> Result<QuoteProperties, Atom> {
    match decode_atom(term)? {
        atom if atom == atoms::as_needed() => Ok(QuoteProperties::AsNeeded),
        atom if atom == atoms::preserve() => Ok(QuoteProperties::Preserve),
        _ => Err(atoms::invalid_option()),
    }
}

fn decode_trailing_comma(term: Term) -> Result<TrailingCommas, Atom> {
    match decode_atom(term)? {
        atom if atom == atoms::all() => Ok(TrailingCommas::All),
        atom if atom == atoms::es5() => Ok(TrailingCommas::Es5),
        atom if atom == atoms::none() => Ok(TrailingCommas::None),
        _ => Err(atoms::invalid_option()),
    }
}

fn decode_semicolons(term: Term) -> Result<Semicolons, Atom> {
    match decode_atom(term)? {
        atom if atom == atoms::always() => Ok(Semicolons::Always),
        atom if atom == atoms::as_needed() => Ok(Semicolons::AsNeeded),
        _ => Err(atoms::invalid_option()),
    }
}

fn decode_arrow_parentheses(term: Term) -> Result<ArrowParentheses, Atom> {
    match decode_atom(term)? {
        atom if atom == atoms::always() => Ok(ArrowParentheses::Always),
        atom if atom == atoms::as_needed() => Ok(ArrowParentheses::AsNeeded),
        _ => Err(atoms::invalid_option()),
    }
}

fn decode_attribute_position(term: Term) -> Result<AttributePosition, Atom> {
    match decode_atom(term)? {
        atom if atom == atoms::auto() => Ok(AttributePosition::Auto),
        atom if atom == atoms::multiline() => Ok(AttributePosition::Multiline),
        _ => Err(atoms::invalid_option()),
    }
}

#[rustler::nif]
fn format_css<'a>(
    env: Env<'a>,
    source: Binary<'a>,
    options: Vec<(Atom, Term<'a>)>,
) -> (Atom, Term<'a>) {
    let input = std::str::from_utf8(source.as_slice()).unwrap();

    let parser_options = match override_css_parser_options(CssParserOptions::default(), &options) {
        Ok(options) => options,
        Err(reason) => return error(reason.to_term(env)),
    };

    let file_source = CssFileSource::css();
    let parsed = biome_css_parser::parse_css(input, file_source, parser_options);
    if parsed.has_errors() {
        return error(parse_error(env, parsed.diagnostics()));
    }

    let css_options = match override_css_options(CssFormatOptions::new(file_source), options) {
        Ok(options) => options,
        Err(reason) => return error(reason.to_term(env)),
    };

    let formatted = biome_css_formatter::format_node(css_options, &parsed.syntax())
        .unwrap()
        .print()
        .unwrap();

    let output = formatted.as_code().as_bytes();

    let mut binary = OwnedBinary::new(output.len()).unwrap();
    binary.as_mut_slice().copy_from_slice(output);

    ok(binary.release(env).to_term(env))
}

fn override_css_options(
    mut format_options: CssFormatOptions,
    options: Vec<(Atom, Term)>,
) -> Result<CssFormatOptions, Atom> {
    for (key, value) in options {
        match key {
            key if key == atoms::indent_style() => {
                format_options.set_indent_style(decode_indent_style(value)?);
            }
            key if key == atoms::indent_width() => {
                format_options.set_indent_width(
                    IndentWidth::try_from(decode_u8(value)?)
                        .map_err(|_| atoms::invalid_option())?,
                );
            }
            key if key == atoms::line_ending() => {
                format_options.set_line_ending(decode_line_ending(value)?);
            }
            key if key == atoms::line_width() => {
                let line_width =
                    LineWidth::try_from(decode_u16(value)?).map_err(|_| atoms::invalid_option())?;
                format_options.set_line_width(line_width);
            }
            key if key == atoms::quote_style() => {
                format_options.set_quote_style(decode_quote_style(value)?);
            }
            key if key == atoms::tailwind_directives() => {}
            _ => return Err(atoms::invalid_option()),
        }
    }

    Ok(format_options)
}

fn override_css_parser_options(
    mut parser_options: CssParserOptions,
    options: &[(Atom, Term)],
) -> Result<CssParserOptions, Atom> {
    for (key, value) in options {
        if *key == atoms::tailwind_directives() && decode_bool(*value)? {
            parser_options = parser_options.allow_tailwind_directives();
        }
    }

    Ok(parser_options)
}

rustler::init!("Elixir.Biomine.Native");
