defmodule Biomine do
  @moduledoc """
  Documentation for `Biomine`.
  """

  @format_js_options NimbleOptions.new!(
                       indent_style: [
                         type: {:in, [:tab, :space]},
                         default: :space,
                         doc: "Indentation style, either `:tab` or `:space`."
                       ],
                       indent_width: [
                         type: :non_neg_integer,
                         default: 2,
                         doc: "Indentation width as an integer."
                       ],
                       line_ending: [
                         type: {:in, [:lf, :crlf, :cr]},
                         default: :lf,
                         doc: "Line ending style, one of `:lf`, `:crlf`, or `:cr`."
                       ],
                       line_width: [
                         type: {:in, 1..320},
                         default: 120,
                         doc: "Maximum line width as an integer from 1 to 320."
                       ],
                       quote_style: [
                         type: {:in, [:double, :single]},
                         doc: "JavaScript quote style, either `:double` or `:single`."
                       ],
                       jsx_quote_style: [
                         type: {:in, [:double, :single]},
                         doc: "JSX quote style, either `:double` or `:single`."
                       ],
                       quote_properties: [
                         type: {:in, [:as_needed, :preserve]},
                         doc:
                           "Object property quote handling, either `:as_needed` or `:preserve`."
                       ],
                       trailing_comma: [
                         type: {:in, [:all, :es5, :none]},
                         doc: "Trailing comma style, one of `:all`, `:es5`, or `:none`."
                       ],
                       semicolons: [
                         type: {:in, [:always, :as_needed]},
                         doc: "Semicolon style, either `:always` or `:as_needed`."
                       ],
                       arrow_parentheses: [
                         type: {:in, [:always, :as_needed]},
                         doc:
                           "Arrow function parentheses style, either `:always` or `:as_needed`."
                       ],
                       bracket_spacing: [
                         type: :boolean,
                         doc: "Whether to print spaces inside object literal brackets."
                       ],
                       bracket_same_line: [
                         type: :boolean,
                         doc: "Whether to keep closing JSX brackets on the same line."
                       ],
                       attribute_position: [
                         type: {:in, [:auto, :multiline]},
                         doc: "JSX attribute position style, either `:auto` or `:multiline`."
                       ]
                     )

  @doc """
  Format JavaScript/TypeScript source.

  Returns `{:ok, formatted_source}` when formatting succeeds.

  Returns `{:error, {:parse_error, diagnostics}}` when the source cannot be
  parsed and `{:error, :invalid_option}` when an unsupported option or option
  value is provided.

  ## Options

  #{NimbleOptions.docs(@format_js_options)}

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
    case NimbleOptions.validate(opts, @format_js_options) do
      {:ok, validated_opts} -> Biomine.Native.format_js(source, validated_opts)
      {:error, %NimbleOptions.ValidationError{}} -> {:error, :invalid_option}
    end
  end

  @doc """
  Format CSS source.

  Returns `{:ok, formatted_source}` when formatting succeeds.

  Returns `{:error, {:parse_error, diagnostics}}` when the source cannot be
  parsed.

  ## Examples

      iex> Biomine.format_css("a{color:red}")
      {:ok, "a {\\n  color: red;\\n}\\n"}

      iex> Biomine.format_css("a {")
      {:error,
       {:parse_error,
        [
          %{
            message: "expected `}` but instead the file ends",
            span: %{start: 3, end: 3}
          }
        ]}}
  """
  def format_css(source) do
    Biomine.Native.format_css(source)
  end
end
