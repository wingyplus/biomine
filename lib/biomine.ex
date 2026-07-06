defmodule Biomine do
  @moduledoc """
  Documentation for `Biomine`.
  """

  @doc """
  Format JavaScript/TypeScript source.

  Returns `{:ok, formatted_source}` when formatting succeeds.

  Returns `{:error, {:parse_error, diagnostics}}` when the source cannot be
  parsed and `{:error, :invalid_option}` when an unsupported option or option
  value is provided.

  ## Options

    * `:indent_style` - indentation style, either `:tab` or `:space`.
    * `:indent_width` - indentation width as an integer.
    * `:line_ending` - line ending style, one of `:lf`, `:crlf`, or `:cr`.
    * `:line_width` - maximum line width as an integer from 1 to 320.
    * `:quote_style` - JavaScript quote style, either `:double` or `:single`.
    * `:jsx_quote_style` - JSX quote style, either `:double` or `:single`.
    * `:quote_properties` - object property quote handling, either
      `:as_needed` or `:preserve`.
    * `:trailing_comma` - trailing comma style, one of `:all`, `:es5`, or
      `:none`.
    * `:semicolons` - semicolon style, either `:always` or `:as_needed`.
    * `:arrow_parentheses` - arrow function parentheses style, either
      `:always` or `:as_needed`.
    * `:bracket_spacing` - whether to print spaces inside object literal
      brackets.
    * `:bracket_same_line` - whether to keep closing JSX brackets on the same
      line.
    * `:attribute_position` - JSX attribute position style, either `:auto` or
      `:multiline`.

  ## Examples

      iex> Biomine.format_js("let x=1")
      {:ok, "let x = 1;\\n"}

      iex> Biomine.format_js("let x='hello'", quote_style: :single)
      {:ok, "let x = 'hello';\\n"}

      iex> Biomine.format_js("funtion f(")
      {:error,
       {:parse_error,
        [
          %{
            message: "Expected a semicolon or an implicit semicolon after a statement, but found none",
            span: %{start: 8, end: 9}
          },
          %{
            message: "expected `)` but instead the file ends",
            span: %{start: 10, end: 10}
          }
        ]}}
  """
  def format_js(source, opts \\ []) do
    Biomine.Native.format_js(source, opts)
  end
end
