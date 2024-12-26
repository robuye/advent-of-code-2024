defmodule Day25 do
  def find_the_answer_p1() do
    "data/day_25.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    input.keys
    |> Enum.flat_map(fn key ->
      input.locks
      |> Enum.map(fn lock ->
        fits =
          key
          |> Enum.with_index()
          |> Enum.all?(fn {k_pin, idx} ->
            k_pin + Enum.at(lock, idx) <= 5
          end)

        {key, lock, fits}
      end)
    end)
    |> Enum.filter(fn {_key, _lock, fits} -> fits end)
    |> length()
  end

  def parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.reduce(%{keys: [], locks: []}, fn schematics, acc ->
      is_lock = String.starts_with?(schematics, "#")

      parsed =
        schematics
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
        |> Enum.group_by(fn {{x, _y}, _chr} -> x end)
        |> Enum.map(fn {_xy, items} ->
          Enum.count(items, fn {_k, v} -> v == "#" end) - 1
        end)

      if is_lock do
        %{acc | locks: [parsed | acc.locks]}
      else
        %{acc | keys: [parsed | acc.keys]}
      end
    end)
  end

  def read_the_input(path), do: File.read!(path)
end
