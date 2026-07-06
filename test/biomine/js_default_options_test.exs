defmodule Biomine.JSDefaultOptionsTest do
  use ExUnit.Case,
    async: true,
    parameterize: [
      %{
        option: "indent_style and indent_width default to 2 spaces",
        source: "if (x) { y(); }",
        output: """
        if (x) {
          y();
        }
        """
      },
      %{
        option: "line_ending defaults to lf",
        source: "let x=1",
        output: "let x = 1;\n"
      },
      %{
        option: "line_width defaults to 120",
        source:
          "const x = [alpha, beta, gamma, delta, epsilon, zeta, eta, theta, iota, kappa, lambda, mu, nu, xi]",
        output: """
        const x = [alpha, beta, gamma, delta, epsilon, zeta, eta, theta, iota, kappa, lambda, mu, nu, xi];
        """
      }
    ]

  test "format_js applies default option value when not provided", %{
    source: source,
    output: output
  } do
    assert {:ok, ^output} = Biomine.format_js(source)
  end
end
