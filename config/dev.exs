use Mix.Config

# Configure your database
config :queue, Queue.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "queue_dev",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
