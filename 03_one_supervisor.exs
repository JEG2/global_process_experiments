defmodule AGlobalProcess do
  use GenServer

  def start_link(args) do
    case GenServer.start_link(__MODULE__, args, name: {:global, __MODULE__}) do
      {:error, {:already_started, _pid}} ->
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

{:ok, first} = Supervisor.start_link([AGlobalProcess], strategy: :one_for_one)
Supervisor.which_children(first)
|> IO.inspect()

{:ok, second} = Supervisor.start_link([AGlobalProcess], strategy: :one_for_one)
Supervisor.which_children(second)
|> IO.inspect()
