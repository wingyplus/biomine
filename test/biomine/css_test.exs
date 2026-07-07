defmodule Biomine.CSSTest do
  use ExUnit.Case,
    async: true,
    parameterize: [
      %{
        source: "a{color:red}",
        output: """
        a {
          color: red;
        }
        """
      },
      %{
        source: "@media (min-width: 768px){.item{display:flex}}",
        output: """
        @media (min-width: 768px) {
          .item {
            display: flex;
          }
        }
        """
      }
    ]

  test "format_css", %{source: source, output: output} do
    assert {:ok, ^output} = Biomine.format_css(source)
  end
end
