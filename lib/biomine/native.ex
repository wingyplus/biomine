defmodule Biomine.Native do
  @moduledoc false

  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :biomine,
    crate: :biomine_native,
    base_url: "#{Mix.Project.config()[:source_url]}/releases/download/v#{version}",
    force_build: System.get_env("BIOMINE_BUILD") in ["1", "true"],
    nif_versions: ["2.15"],
    version: version,
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      aarch64-unknown-linux-musl
      x86_64-apple-darwin
      x86_64-pc-windows-gnu
      x86_64-pc-windows-msvc
      x86_64-unknown-linux-gnu
      x86_64-unknown-linux-musl
    )

  def format_js(_source, _opts), do: :erlang.nif_error(:nif_not_loaded)
  def format_css(_source), do: :erlang.nif_error(:nif_not_loaded)
end
