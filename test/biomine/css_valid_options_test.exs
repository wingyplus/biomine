defmodule Biomine.CSSValidOptionsTest do
  use ExUnit.Case,
    async: true,
    parameterize: [
      %{
        option: "indent_style",
        source: "a{color:red}",
        opts: [indent_style: :tab],
        output: """
        a {
        \tcolor: red;
        }
        """
      },
      %{
        option: "indent_width",
        source: "a{color:red}",
        opts: [indent_style: :space, indent_width: 4],
        output: """
        a {
            color: red;
        }
        """
      },
      %{
        option: "line_ending",
        source: "a{color:red}",
        opts: [line_ending: :crlf],
        output: "a {\r\n  color: red;\r\n}\r\n"
      },
      %{
        option: "line_width",
        source: "a { color: red; background-color: blue; }",
        opts: [line_width: 20],
        output: """
        a {
          color: red;
          background-color: blue;
        }
        """
      },
      %{
        option: "quote_style",
        source: ~s(a{content:"hi"}),
        opts: [quote_style: :single],
        output: """
        a {
          content: 'hi';
        }
        """
      }
    ]

  test "format_css applies option", %{source: source, opts: opts, output: output} do
    assert {:ok, ^output} = Biomine.format_css(source, opts)
  end
end
