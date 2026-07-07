defmodule Biomine.Mix.JsFormatter do
  @moduledoc """
  Mix formatter plugin for JavaScript and TypeScript files.
  """

  @behaviour Mix.Tasks.Format

  @extensions ~w(.cjs .cts .js .jsx .mjs .mts .ts .tsx)

  @impl Mix.Tasks.Format
  def features(_opts) do
    [extensions: @extensions]
  end

  @impl Mix.Tasks.Format
  def format(contents, opts) do
    biomine_opts = opts |> Keyword.get(:biomine, []) |> Keyword.get(:js, [])

    case Biomine.format_js(contents, biomine_opts) do
      {:ok, formatted} -> formatted
      {:error, :invalid_option} -> Mix.raise("invalid Biomine formatter option")
      {:error, {:parse_error, diagnostics}} -> Mix.raise(parse_error_message(diagnostics))
    end
  end

  defp parse_error_message([%{message: message} | _]) do
    "could not format JavaScript/TypeScript: #{message}"
  end
end
