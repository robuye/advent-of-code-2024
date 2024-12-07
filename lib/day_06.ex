defmodule Day06 do
  def find_the_answer_p1() do
    "test/data/day_06.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def find_the_answer_p2() do
    "data/day_06.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p2()
  end

  def play_the_game_p2(input) do
    {guard_position, guard_direction} =
      Enum.find_value(input, fn
        {coordinates, {:guard, direction}} -> {coordinates, direction}
        _ -> nil
      end)

    initial_state = %{
      board: input,
      obstacles: [],
      guard: %{
        positions: [{guard_position, guard_direction}],
        direction: guard_direction,
        turns: 0
      },
      game_completed: false
    }

    completed_state = walk_path(initial_state)

    (completed_state.guard.positions -- initial_state.guard.positions)
    |> Enum.reduce(initial_state, fn {{x, y}, _} = step, acc ->
      prev_position =
        Enum.at(
          completed_state.guard.positions,
          Enum.find_index(completed_state.guard.positions, &(&1 == step)) + 1
        )

      initial_state
      |> add_obstacle({x, y})
      |> teleport_guard(prev_position)
      |> walk_path()
      |> case do
        :loop_detected -> %{acc | obstacles: Enum.uniq([{x, y} | acc.obstacles])}
        _ -> acc
      end
    end)
    |> then(& &1.obstacles)
    |> Enum.count()
  end

  def play_the_game_p1(input) do
    {guard_position, guard_direction} =
      Enum.find_value(input, fn
        {coordinates, {:guard, direction}} -> {coordinates, direction}
        _ -> nil
      end)

    initial_state = %{
      board: input,
      guard: %{
        positions: [{guard_position, guard_direction}],
        direction: guard_direction,
        turns: 0
      },
      game_completed: false
    }

    result = walk_path(initial_state)

    result.guard.positions
    |> Enum.uniq_by(fn {coords, _direction} -> coords end)
    |> Enum.count()
  end

  def walk_path(initial_state) do
    Stream.iterate(1, &(&1 + 1))
    |> Enum.reduce_while(initial_state, fn _step, state ->
      new_state = step_forward(state)

      has_duplicates = Enum.uniq(new_state.guard.positions) != new_state.guard.positions

      cond do
        new_state.game_completed == true -> {:halt, new_state}
        has_duplicates == true -> {:halt, :loop_detected}
        true -> {:cont, new_state}
      end
    end)
  end

  def step_forward(%{board: board, guard: guard} = state) do
    [{{orig_x, orig_y}, _direction} | _] = guard.positions

    new_position =
      case guard.direction do
        :up -> {orig_x, orig_y - 1}
        :right -> {orig_x + 1, orig_y}
        :down -> {orig_x, orig_y + 1}
        :left -> {orig_x - 1, orig_y}
      end

    board
    |> Enum.find(fn {position, _item} -> position == new_position end)
    |> case do
      {_position, "#"} ->
        if guard.turns < 4 do
          turn_right(state)
        else
          %{state | game_completed: true}
        end

      {_, _} ->
        new_guard = %{
          positions: [{new_position, guard.direction} | guard.positions],
          direction: guard.direction,
          turns: 0
        }

        %{state | guard: new_guard}

      nil ->
        %{state | game_completed: true}
    end
  end

  def turn_right(%{guard: guard} = state) do
    all_directions = [:up, :right, :down, :left]
    direction_idx = Enum.find_index(all_directions, &(&1 == guard.direction))

    next_direction =
      Stream.cycle(all_directions)
      |> Enum.at(direction_idx + 1)

    %{
      state
      | guard: %{
          positions: guard.positions,
          direction: next_direction,
          turns: guard.turns + 1
        }
    }
  end

  def teleport_guard(state, {_, direction} = position) do
    %{state | guard: %{state.guard | positions: [position], direction: direction}}
  end

  def add_obstacle(state, coords) do
    target_idx =
      state.board
      |> Enum.find_index(fn
        {^coords, _item} -> true
        _other -> false
      end)

    new_board =
      state.board
      |> List.replace_at(target_idx, {coords, "#"})

    %{state | board: new_board}
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, y} ->
      row
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn
        {"#", x} -> {{x, y}, "#"}
        {"^", x} -> {{x, y}, {:guard, :up}}
        {_, x} -> {{x, y}, nil}
      end)
    end)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end

  def print_board(state) do
    [{{g_x, g_y}, _direction} | _] = state.guard.positions

    Enum.each(0..9, fn y ->
      Enum.each(0..9, fn x ->
        Enum.find_value(state.board, fn
          {{^x, ^y}, "#"} -> "#"
          {{^x, ^y}, _} when x == g_x and y == g_y -> "@"
          {{^x, ^y}, _} -> "."
          _ -> nil
        end)
        |> IO.write()
      end)

      IO.write("\n")
    end)

    state
  end
end
