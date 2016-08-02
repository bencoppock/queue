defmodule Queue.Provider do
  alias Experimental.GenStage
  use GenStage
  alias Queue.Repo
  import Ecto.Query

  def start_link do
    GenStage.start_link(__MODULE__, 0, name: __MODULE__)
  end

  def init(initial_state) do
    {:producer, initial_state}
  end

  def handle_demand(new_demand, existing_demand) when new_demand > 0 do
    demand = new_demand + existing_demand
    {:ok, {count, tasks}} = take_tasks(demand)
    {:noreply, tasks, demand - count}
  end

  def handle_info(:new_tasks_available, demand) do
    {:ok, {count, tasks}} = take_tasks(demand)
    {:noreply, tasks, demand - count}
  end

  defp take_tasks(limit) do
    Repo.transaction fn ->
      ids = Repo.all waiting_tasks(limit)
      Repo.update_all by_ids(ids),
        [set: [status: "running"]],
        [returning: [:id, :payload]]
    end
  end

  defp by_ids(ids) do
    from t in "tasks", where: t.id in ^ids
  end

  defp waiting_tasks(limit) do
    from t in Queue.Task,
      where: t.status == "waiting",
      limit: ^limit,
      select: t.id,
      lock: "FOR UPDATE" # "FOR UPDATE SKIP LOCKED" for PG 9.5 (i.e. skip locked rows, don't wait)
  end
end
