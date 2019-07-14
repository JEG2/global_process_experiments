defmodule AGlobalProcess do
  use GenServer

  def start_link(args) do
    IO.puts "Attempting a start on #{inspect Node.self()}…"
    case GenServer.start_link(__MODULE__, args, name: {:global, __MODULE__}) do
      {:error, {:already_started, _pid}} ->
        IO.puts "Ignored."
        :ignore

      result ->
        result
    end
  end

  def init(_args) do
    IO.puts "Starting #{inspect self()}…"
    {:ok, %{ }}
  end
end

defmodule NodeMonitor do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    :net_kernel.monitor_nodes(true)
    {:ok, %{ }}
  end

  def handle_info({:nodeup, _node}, %{ } = state) do
    Supervisor.which_children(MySupervisor)
    |> IO.inspect()
    {:noreply, state}
  end

  def handle_info({:nodedown, _node}, %{ } = state) do
    Supervisor.which_children(MySupervisor)
    |> IO.inspect()

    Supervisor.restart_child(MySupervisor, AGlobalProcess)

    Supervisor.which_children(MySupervisor)
    |> IO.inspect()

    {:noreply, state}
  end
end

{:ok, _supervisor} = Supervisor.start_link(
  [
    AGlobalProcess,
    NodeMonitor
  ],
  strategy: :one_for_one,
  name: MySupervisor
)
Supervisor.which_children(MySupervisor)
|> IO.inspect()

case Node.self() |> to_string() |> String.split("@") do
  ["one", _machine] ->
    Process.sleep(:infinity)

  ["two", machine] ->
    true = Node.connect(:"one@#{machine}")
    Process.sleep(:infinity)

  _other ->
    IO.puts "Please use `--sname one` and `--sname two`"
end
