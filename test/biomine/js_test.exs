defmodule Biomine.JSTest do
  use ExUnit.Case,
    async: true,
    parameterize: [
      %{
        input: "let x=1",
        output: """
        let x = 1;
        """
      },
      %{
        input: "let x:string='hello'",
        output: """
        let x: string = "hello";
        """
      }
    ]

  test "format_js", %{input: input, output: output} do
    assert {:ok, ^output} = Biomine.format_js(input)
  end
end
