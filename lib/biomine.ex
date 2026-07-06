defmodule Biomine do
  @moduledoc """
  Documentation for `Biomine`.
  """

  @doc """
  Format JavaScript/TypeScript source.
  """
  def format_js(source, opts \\ []) do
    Biomine.Native.format_js(source, opts)
  end
end
