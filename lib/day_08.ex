defmodule Day08 do
  def find_the_answer_p1() do
    "data/day_08.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    antennas =
      input
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, y} ->
        row
        |> Enum.with_index()
        |> Enum.map(fn
          {".", _x} -> nil
          {antenna, x} -> %{x: x, y: y, freq: antenna}
        end)
        |> Enum.filter(& &1)
      end)

    initial_state = %{
      max_x: length(hd(input)) - 1,
      max_y: length(input) - 1,
      antennas: [],
      antinodes: []
    }

    result =
      antennas
      |> Enum.reduce(initial_state, fn antenna, state ->
        state
        |> place_antinodes(antenna)
        |> place_antenna(antenna)
      end)

    length(result.antinodes)
  end

  defp place_antenna(state, antenna) do
    %{state | antennas: [antenna | state.antennas]}
  end

  defp place_antinodes(state, antenna) do
    new_antinodes =
      state.antennas
      |> Enum.flat_map(fn
        other_antenna when antenna.freq == other_antenna.freq ->
          distance_x = abs(antenna.x - other_antenna.x)
          distance_y = abs(antenna.y - other_antenna.y)

          direction_x = if(other_antenna.x > antenna.x, do: :right, else: :left)
          direction_y = if(other_antenna.y > antenna.y, do: :down, else: :up)

          other_antinode_x =
            if(direction_x == :right,
              do: other_antenna.x + distance_x,
              else: other_antenna.x - distance_x
            )

          other_antinode_y =
            if(direction_y == :down,
              do: other_antenna.y + distance_y,
              else: other_antenna.y - distance_y
            )

          self_antinode_x =
            if(direction_x == :right,
              do: antenna.x - distance_x,
              else: antenna.x + distance_x
            )

          self_antinode_y =
            if(direction_y == :down,
              do: antenna.y - distance_y,
              else: antenna.y + distance_y
            )

          [
            %{x: other_antinode_x, y: other_antinode_y, freq: antenna.freq},
            %{x: self_antinode_x, y: self_antinode_y, freq: antenna.freq}
          ]
          |> Enum.filter(&(&1.x >= 0 and &1.x <= state.max_x))
          |> Enum.filter(&(&1.y >= 0 and &1.y <= state.max_y))

        _other_antenna ->
          []
      end)

    all_antinodes =
      (state.antinodes ++ new_antinodes)
      |> Enum.uniq_by(&{&1.x, &1.y})

    %{state | antinodes: all_antinodes}
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line -> String.graphemes(line) end)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
