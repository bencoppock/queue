use Mix.Config

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :queue, Queue.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "queue_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
