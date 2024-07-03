import Config

config :evaluate_aws_translate,
  aws_access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  aws_secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")
