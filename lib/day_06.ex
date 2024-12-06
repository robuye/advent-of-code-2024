defmodule Day06 do
  def find_the_answer_p1() do
    "data/day_06.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
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
        positions: [guard_position],
        direction: guard_direction,
        turns: 0
      },
      game_completed: false
    }

    result =
      Stream.iterate(1, &(&1 + 1))
      |> Enum.reduce_while(initial_state, fn _, state ->
        new_state = step_forward(state)

        if new_state.game_completed do
          {:halt, new_state}
        else
          {:cont, new_state}
        end
      end)

    result.guard.positions
    |> Enum.uniq()
    |> Enum.count()
  end

  def step_forward(%{board: board, guard: guard} = state) do
    [{orig_x, orig_y} | _] = guard.positions

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
        if guard.turns == 0 do
          turn_right(state)
        else
          %{state | game_completed: true}
        end

      {_, _} ->
        new_guard = %{
          positions: [new_position | guard.positions],
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

    %{turns: 0} = guard

    %{
      state
      | guard: %{
          positions: guard.positions,
          direction: next_direction,
          turns: guard.turns + 1
        }
    }
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
end
