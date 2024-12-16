defmodule Day16 do
  def find_the_answer_p1() do
    "data/day_16.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    {{start_x, start_y}, "S"} =
      input
      |> Map.to_list()
      |> Enum.find(fn {_k, v} -> v == "S" end)

    {{stop_x, stop_y}, "E"} =
      input
      |> Map.to_list()
      |> Enum.find(fn {_k, v} -> v == "E" end)

    initial_move = %{
      x: start_x,
      y: start_y,
      parent: nil,
      cost: 0,
      turns: 0,
      direction: :east
    }

    a_star(%{
      map: input,
      visited: [],
      candidates: [initial_move],
      stop_at: {stop_x, stop_y},
      direction: :east
    })
    |> Enum.map(&(&1.turns * 1000 + 1))
    |> Enum.sum()
  end

  def a_star(state) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(state, fn _i, state ->
      {stop_x, stop_y} = state.stop_at

      {current_move, candidates} = List.pop_at(state.candidates, 0)

      visited = [current_move | state.visited]

      if {current_move.x, current_move.y} == state.stop_at do
        {:halt, %{state | visited: visited, candidates: []}}
      else
        neightbors =
          [
            %{x: current_move.x - 1, y: current_move.y, direction: :west},
            %{x: current_move.x + 1, y: current_move.y, direction: :east},
            %{x: current_move.x, y: current_move.y - 1, direction: :north},
            %{x: current_move.x, y: current_move.y + 1, direction: :south}
          ]
          |> Enum.reject(fn %{x: x, y: y} -> state.map[{x, y}] == "#" end)
          |> Enum.reject(fn %{x: x, y: y} ->
            Enum.find(state.visited, &(&1.x == x and &1.y == y))
          end)
          |> Enum.map(fn %{x: nx, y: ny, direction: direction} ->
            turns =
              case {current_move.direction, direction} do
                {a, b} when a == b -> 0
                {a, b} when a in [:north, :south] -> if(b in [:east, :west], do: 1, else: 2)
                {a, b} when a in [:east, :west] -> if(b in [:north, :south], do: 1, else: 2)
              end

            %{
              x: nx,
              y: ny,
              direction: direction,
              parent: {current_move.x, current_move.y},
              turns: turns,
              cost: current_move.cost + 1 + turns * 1000,
              distance_to_end: abs(nx - stop_x) + abs(ny - stop_y)
            }
          end)

        candidates =
          (neightbors ++ candidates)
          |> Enum.sort_by(fn x -> x.distance_to_end + x.cost end, :asc)
          |> Enum.uniq_by(fn move -> {move.x, move.y} end)

        {:cont,
         %{state | visited: visited, candidates: candidates, direction: current_move.direction}}
      end
    end)
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

      path
    end)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {chr, x} ->
        {{x, y}, chr}
      end)
    end)
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
          "." -> acc <> " "
          nil -> acc
          chr -> acc <> chr
        end
      end)
    end)
    |> Enum.each(&IO.puts/1)

    IO.puts("")

    :ok
  end
end
