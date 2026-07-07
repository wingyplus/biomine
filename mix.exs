defmodule Biomine.MixProject do
  use Mix.Project

  @version File.read!("VERSION") |> String.trim()
  @source_url "https://github.com/wingyplus/biomine"

  def project do
    [
      app: :biomine,
      version: @version,
      description: "Elixir bindings for the Biome formatter",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      source_url: @source_url,
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:rustler_precompiled, "~> 0.9"},
      # rustler is only needed to compile the NIF from source (force_build, the
      # CI release build, or when no precompiled artifact exists for the target).
      {:rustler, ">= 0.0.0", optional: true},
      {:nimble_options, "~> 1.1"},
      # phoenix_live_view is only needed to implement Biomine.LiveView.TagFormatter;
      # host applications must already depend on it to use Phoenix.LiveView.HTMLFormatter.
      {:phoenix_live_view, "~> 1.2", optional: true},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp package do
    [
      files: [
        "LICENSE",
        "lib",
        "native/biomine_native/src",
        "native/biomine_native/Cargo.toml",
        # Workspace root manifest + lockfile: cargo walks up to the workspace
        # root when building the crate from source (force_build).
        "Cargo.toml",
        "Cargo.lock",
        "checksum-*.exs",
        "mix.exs",
        "VERSION"
      ],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp aliases do
    [
      format: ["format", "cmd --cd native/biomine_native cargo fmt"]
    ]
  end
end
