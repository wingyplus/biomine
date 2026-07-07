defmodule Biomine.CSSInvalidOptionsTest do
  use ExUnit.Case,
    async: true,
    parameterize: [
      %{option: "indent_style", opts: [indent_style: :invalid]},
      %{option: "indent_width", opts: [indent_width: :invalid]},
      %{option: "line_ending", opts: [line_ending: :invalid]},
      %{option: "line_width", opts: [line_width: 0]},
      %{option: "quote_style", opts: [quote_style: :invalid]},
      %{option: "unknown", opts: [unknown: :option]}
    ]

  test "format_css rejects invalid option", %{opts: opts} do
    assert {:error, :invalid_option} = Biomine.format_css("a{color:red}", opts)
  end
end
