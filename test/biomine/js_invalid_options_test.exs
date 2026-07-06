defmodule Biomine.JSInvalidOptionsTest do
  use ExUnit.Case,
    async: true,
    parameterize: [
      %{option: "indent_style", opts: [indent_style: :invalid]},
      %{option: "indent_width", opts: [indent_width: :invalid]},
      %{option: "line_ending", opts: [line_ending: :invalid]},
      %{option: "line_width", opts: [line_width: 0]},
      %{option: "quote_style", opts: [quote_style: :invalid]},
      %{option: "jsx_quote_style", opts: [jsx_quote_style: :invalid]},
      %{option: "quote_properties", opts: [quote_properties: :invalid]},
      %{option: "trailing_comma", opts: [trailing_comma: :invalid]},
      %{option: "semicolons", opts: [semicolons: :invalid]},
      %{option: "arrow_parentheses", opts: [arrow_parentheses: :invalid]},
      %{option: "bracket_spacing", opts: [bracket_spacing: :invalid]},
      %{option: "bracket_same_line", opts: [bracket_same_line: :invalid]},
      %{option: "attribute_position", opts: [attribute_position: :invalid]},
      %{option: "unknown", opts: [unknown: :option]}
    ]

  test "format_js rejects invalid option", %{opts: opts} do
    assert {:error, :invalid_option} = Biomine.format_js("let x = 1", opts)
  end
end
