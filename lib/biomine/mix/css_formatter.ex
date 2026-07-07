defmodule Biomine.Mix.CssFormatter do
  @moduledoc """
  Mix formatter plugin for CSS files.
  """

  @behaviour Mix.Tasks.Format

  @extensions ~w(.css)

  @impl Mix.Tasks.Format
  def features(_opts) do
    [extensions: @extensions]
  end

  @impl Mix.Tasks.Format
  def format(contents, opts) do
    biomine_opts = opts |> Keyword.get(:biomine, []) |> Keyword.get(:css, [])

    case Biomine.format_css(contents, biomine_opts) do
      {:ok, formatted} -> formatted
      {:error, :invalid_option} -> Mix.raise("invalid Biomine formatter option")
      {:error, {:parse_error, diagnostics}} -> Mix.raise(parse_error_message(diagnostics))
    end
  end

  defp parse_error_message([%{message: message} | _]) do
    "could not format CSS: #{message}"
  end
end
