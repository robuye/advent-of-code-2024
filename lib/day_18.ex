defmodule Day18 do
  def find_the_answer_p1() do
    "data/day_18.txt"
    |> read_the_input()
    |> parse(1024)
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    initial_move = %{
      x: 0,
      y: 0,
      parent: nil,
      cost: 0
    }

    dijkstra(%{
      map: input,
      visited: [],
      candidates: [initial_move],
      stop_at: {70, 70}
    })
    |> then(fn state ->
      path =
        Stream.iterate(1, &(&1 + 1))
        |> Enum.reduce_while(Enum.take(state.visited, 1), fn _i, acc ->
          [last_move | _] = acc

          if last_move.parent do
            {px, py} = last_move.parent
            parent = Enum.find(state.visited, &(&1.x == px and &1.y == py))
            {:cont, [parent | acc]}
          else
            {:halt, List.delete_at(acc, 0)}
          end
        end)

      path
      |> Enum.reduce(state.map, fn move, map ->
        Map.put(map, {move.x, move.y}, "*")
      end)
      |> print_grid()

      length(path)
    end)
  end

  def dijkstra(state) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(state, fn _i, state ->
      {current_move, candidates} =
        List.pop_at(state.candidates, 0)

      visited =
        [current_move | state.visited]
        |> Enum.filter(& &1)

      if {current_move.x, current_move.y} == state.stop_at do
        {:halt, %{state | visited: visited, candidates: []}}
      else
        neightbors =
          [
            %{x: current_move.x - 1, y: current_move.y},
            %{x: current_move.x + 1, y: current_move.y},
            %{x: current_move.x, y: current_move.y - 1},
            %{x: current_move.x, y: current_move.y + 1}
          ]
          |> Enum.reject(fn %{x: x, y: y} -> state.map[{x, y}] == "#" end)
          |> Enum.filter(fn %{x: x, y: y} -> x in 0..70 and y in 0..70 end)
          |> Enum.reject(fn %{x: x, y: y} ->
            Enum.find(state.visited, &(&1.x == x and &1.y == y))
          end)
          |> Enum.map(fn %{x: nx, y: ny} ->
            %{
              x: nx,
              y: ny,
              parent: {current_move.x, current_move.y},
              cost: current_move.cost + 1
            }
          end)

        candidates =
          (neightbors ++ candidates)
          |> Enum.sort_by(& &1.cost, :asc)
          |> Enum.uniq_by(fn move -> {move.x, move.y} end)

        {:cont, %{state | visited: visited, candidates: candidates}}
      end
    end)
  end

  def parse(input, len) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn xy_str ->
      Regex.scan(~r/\d+/, xy_str)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.take(len)
    |> Enum.map(fn [x, y] -> {{x, y}, "#"} end)
    |> Enum.into(%{})
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end

  defp print_grid(map) do
    # %{{x, y} => <character to print>}

    {{max_x, _}, _} = Enum.max_by(map, fn {{x, _y}, _} -> x end)
    {{_, max_y}, _} = Enum.max_by(map, fn {{_x, y}, _} -> y end)

    IO.puts("")

    Enum.map(0..max_y, fn y ->
      Enum.reduce(0..max_x, "", fn x, acc ->
        chr = map[{x, y}]

        case chr do
          nil -> acc <> "."
          chr -> acc <> chr
        end
      end)
    end)
    |> Enum.each(&IO.puts/1)

    IO.puts("")

    :ok
  end
end
