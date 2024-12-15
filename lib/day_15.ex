defmodule Day15 do
  def find_the_answer_p1() do
    "data/day_15.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    IO.puts("Initial map:")
    print_grid(input.map)

    state =
      input.moves
      |> Enum.reduce(input, fn direction, state ->
        make_a_move(state, {state.robot.x, state.robot.y}, direction)
      end)

    IO.puts("Map at the end:")
    print_grid(state.map)

    state.map
    |> Enum.filter(fn {_k, chr} -> chr == "O" end)
    |> Enum.map(fn {{x, y}, _chr} ->
      x + y * 100
    end)
    |> Enum.sum()
  end

  defp make_a_move(state, {from_x, from_y}, direction) do
    target_xy =
      case direction do
        :left -> {from_x - 1, from_y}
        :right -> {from_x + 1, from_y}
        :up -> {from_x, from_y - 1}
        :down -> {from_x, from_y + 1}
      end

    case state.map[target_xy] do
      x when x in [".", "@"] ->
        {new_x, new_y} = target_xy

        new_map =
          state.map
          |> Map.put({from_x, from_y}, ".")
          |> Map.put(target_xy, "@")

        %{state | robot: %{x: new_x, y: new_y}, map: new_map}

      "#" ->
        state

      "O" ->
        push_box(state, target_xy, direction)
        |> case do
          {true, state} -> make_a_move(state, {from_x, from_y}, direction)
          {false, state} -> state
        end
    end
  end

  defp push_box(state, {from_x, from_y}, direction) do
    target_xy =
      case direction do
        :left -> {from_x - 1, from_y}
        :right -> {from_x + 1, from_y}
        :up -> {from_x, from_y - 1}
        :down -> {from_x, from_y + 1}
      end

    case state.map[target_xy] do
      "#" ->
        {false, state}

      "O" ->
        push_box(state, target_xy, direction)

      "." ->
        new_map =
          state.map
          |> Map.put({from_x, from_y}, ".")
          |> Map.put(target_xy, "O")

        {true, %{state | map: new_map}}
    end
  end

  defp print_grid(map) do
    {{max_x, _}, _} = Enum.max_by(map, fn {{x, _y}, _} -> x end)
    {{_, max_y}, _} = Enum.max_by(map, fn {{_x, y}, _} -> y end)

    IO.puts("")

    Enum.map(0..max_y, fn y ->
      Enum.reduce(0..max_x, "", fn x, acc ->
        chr = map[{x, y}]

        if chr do
          acc <> chr
        else
          acc
        end
      end)
    end)
    |> Enum.each(&IO.puts/1)

    IO.puts("")

    :ok
  end

  def parse(input) do
    [map_str, moves_str] =
      input
      |> String.split("\n\n")

    map =
      map_str
      |> String.split("\n")
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

    {{r_x, r_y}, _} = Enum.find(map, fn {_, chr} -> chr == "@" end)

    moves =
      moves_str
      |> String.split("", trim: true)
      |> Enum.map(fn
        "^" -> :up
        "v" -> :down
        ">" -> :right
        "<" -> :left
        _ -> nil
      end)
      |> Enum.filter(& &1)

    %{map: map, moves: moves, robot: %{x: r_x, y: r_y}, step: 0}
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
