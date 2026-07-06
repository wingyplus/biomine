defmodule Biomine.JSTest do
  use ExUnit.Case,
    async: true,
    parameterize: [
      %{
        source: "let x=1",
        output: """
        let x = 1;
        """
      },
      %{
        source: "let x:string='hello'",
        output: """
        let x: string = "hello";
        """
      }
    ]

  test "format_js", %{source: source, output: output} do
    assert {:ok, ^output} = Biomine.format_js(source)
  end
end
