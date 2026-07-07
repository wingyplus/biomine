defmodule Biomine.CSSDefaultOptionsTest do
  use ExUnit.Case,
    async: true,
    parameterize: [
      %{
        option: "indent_style and indent_width default to 2 spaces",
        source: "a{color:red}",
        output: """
        a {
          color: red;
        }
        """
      },
      %{
        option: "line_ending defaults to lf",
        source: "a{color:red}",
        output: "a {\n  color: red;\n}\n"
      },
      %{
        option: "line_width defaults to 120",
        source: "a { color: red; background-color: blue; border: 1px solid black; }",
        output: """
        a {
          color: red;
          background-color: blue;
          border: 1px solid black;
        }
        """
      }
    ]

  test "format_css applies default option value when not provided", %{
    source: source,
    output: output
  } do
    assert {:ok, ^output} = Biomine.format_css(source)
  end
end
