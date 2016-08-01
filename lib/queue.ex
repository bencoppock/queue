defmodule Queue do
  use Application
  import Ecto.Query

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      supervisor(Queue.Repo, []),
      supervisor(Task.Supervisor, [[name: Queue.TaskSupervisor]]),
      worker(Queue.Provider, [])
    ]

    # Start roughly twice as many queue workers as we have cores
    # since some workers may sometimes wait for IO, etc.
    queue_workers =
      for id <- 1..(System.schedulers_online * 2) do
        worker(Queue.Worker, [], id: id)
      end

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Queue.Supervisor]
    Supervisor.start_link(children ++ queue_workers, opts)
  end

  def enqueue(module, function, args) do
    payload = :erlang.term_to_binary {module, function, args}
    Queue.Repo.insert_all "tasks", [%{status: "waiting", payload: payload}]
    send Queue.Provider, :new_tasks_available
  end

  def update_status(task_id, status) do
    Queue.Task
    |> Queue.Repo.get(task_id)
    |> Queue.Task.changeset(%{status: status})
    |> Queue.Repo.update
  end
end
