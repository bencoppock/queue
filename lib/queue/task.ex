defmodule Queue.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :payload, :binary
    field :status, :string

    timestamps
  end

  def changeset(task, params \\ %{}) do
    task
    |> cast(params, [:payload, :status])
    |> validate_required([:payload, :status])
  end
end
