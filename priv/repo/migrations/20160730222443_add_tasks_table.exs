defmodule Queue.Repo.Migrations.AddTasksTable do
  use Ecto.Migration

  def change do
    create table(:tasks) do
      add :payload, :binary, null: false
      add :status, :string
    end
  end
end
