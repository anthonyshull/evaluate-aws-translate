defmodule EvaluateAwsTranslate.MixProject do
  use Mix.Project

  def project do
    [
      app: :evaluate_aws_translate,
      version: "0.0.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {EvaluateAwsTranslate.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:aws, "1.0.2"},
      {:finch, "0.18.0"},
      {:jason, "1.4.3"},
      {:recase, "0.8.1"}
    ]
  end
end
