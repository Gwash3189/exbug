defmodule Exbug.Mixfile do
  use Mix.Project
  @description """
  A more traditional experience for the :debugger module
  """
  def project do
    [app: :exbug,
     version: "0.0.1",
     elixir: "~> 1.4",
     name: "Exbug",
     description: @description,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     package: package(),
     source_url: "https://github.com/gwash3189/exbug",
     homepage_url: "https://github.com/gwash3189/exbug",
     docs: [main: "Exbug"],
     deps: deps()]
  end

  defp package do
  [
    maintainers: ["Adam Beck"],
    licenses: ["MIT"],
    links: %{"Github" => "https://github.com/Gwash3189/exbug"}
  ]
end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: []]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:ex_doc, "~> 0.14", only: :dev, runtime: false}]
  end
end
