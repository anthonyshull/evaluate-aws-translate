defmodule EvaluateAwsTranslate.Application do
  @moduledoc false

  use Application

  @finch Application.compile_env(:evaluate_aws_translate, :finch)

  @impl Application
  def start(_type, _args) do
    children = [
      {Finch, name: @finch}
    ]

    opts = [strategy: :one_for_one, name: EvaluateAwsTranslate.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
