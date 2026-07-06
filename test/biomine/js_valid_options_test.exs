defmodule Biomine.JSValidOptionsTest do
  use ExUnit.Case,
    async: true,
    parameterize: [
      %{
        option: "indent_style",
        source: "if (x) { y(); }",
        opts: [indent_style: :space],
        output: """
        if (x) {
              y();
            }
        """
      },
      %{
        option: "indent_width",
        source: "if (x) { y(); }",
        opts: [indent_style: :space, indent_width: 4],
        output: """
        if (x) {
                    y();
                }
        """
      },
      %{
        option: "line_ending",
        source: "let x=1",
        opts: [line_ending: :crlf],
        output: """
        let x = 1;\r
        """
      },
      %{
        option: "line_width",
        source: "const x = [alpha, beta, gamma]",
        opts: [line_width: 20],
        output: """
        const x = [
        \t\t\talpha,
        \t\t\tbeta,
        \t\t\tgamma,
        \t\t];
        """
      },
      %{
        option: "quote_style",
        source: "let x='hello'",
        opts: [quote_style: :single],
        output: """
        let x = 'hello';
        """
      },
      %{
        option: "quote_properties",
        source: "const x = {\"foo\": 1}",
        opts: [quote_properties: :preserve],
        output: """
        const x = { "foo": 1 };
        """
      },
      %{
        option: "trailing_comma",
        source: "const x = [alpha, beta, gamma]",
        opts: [line_width: 20, trailing_comma: :none],
        output: """
        const x = [
        \t\t\talpha,
        \t\t\tbeta,
        \t\t\tgamma
        \t\t];
        """
      },
      %{
        option: "semicolons",
        source: "let x=1",
        opts: [semicolons: :as_needed],
        output: """
        let x = 1
        """
      },
      %{
        option: "arrow_parentheses",
        source: "const f=(x)=>x",
        opts: [arrow_parentheses: :as_needed],
        output: """
        const f = x => x;
        """
      },
      %{
        option: "bracket_spacing",
        source: "const x={foo:1,bar:2}",
        opts: [bracket_spacing: false],
        output: """
        const x = {foo: 1, bar: 2};
        """
      },
      %{
        option: "jsx_quote_style",
        source: "let x=1",
        opts: [jsx_quote_style: :single],
        output: """
        let x = 1;
        """
      },
      %{
        option: "bracket_same_line",
        source: "let x=1",
        opts: [bracket_same_line: true],
        output: """
        let x = 1;
        """
      },
      %{
        option: "attribute_position",
        source: "let x=1",
        opts: [attribute_position: :multiline],
        output: """
        let x = 1;
        """
      }
    ]

  test "format_js applies option", %{source: source, opts: opts, output: output} do
    assert {:ok, ^output} = Biomine.format_js(source, opts)
  end
end
