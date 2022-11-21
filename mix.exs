defmodule PLM.Mixfile do
  use Mix.Project

  def project() do
    [
      app: :plm,
      version: "0.8.1",
      elixir: "~> 1.7",
      description: "PLM Product Lifecycle Management",
      package: package(),
      deps: deps()
    ]
  end

  def package do
    [
      files: ~w(doc lib mix.exs LICENSE),
      licenses: ["ISC"],
      maintainers: ["Namdak Tonpa"],
      name: :plm,
      links: %{"GitHub" => "https://github.com/o7/plm"}
    ]
  end

  def application() do
    [
      mod: {PLM.Application, []},
      applications: [:syn, :form, :schema, :dec, :nitro, :ranch, :cowboy, :rocksdb, :kvs, :bpe, :n2o]
    ]
  end

  def deps() do
    [
      {:ex_doc, "~> 0.20.2", only: :dev},
      {:cowboy, "~> 2.9.0"},
      {:rocksdb, "~> 1.6.0"},
      {:syn, "2.1.0"},
      {:dec, "~> 0.10.2"},
      {:bpe, "~> 7.11.0"},
      {:nitro, "~> 7.10.0"},
      {:form, "~> 7.10.0"},
      {:schema, "~> 3.11.3"},
      {:kvs, "~> 9.4.8"},
      {:n2o, "~> 9.11.1"}
    ]
  end
end
