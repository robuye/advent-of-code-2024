defmodule Day23 do
  def find_the_answer_p1() do
    "data/day_23.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(connections_map) do
    connections_map
    |> Enum.flat_map(fn {k1, k1_connections} ->
      k1_connections
      |> Enum.reduce([], fn k2, acc ->
        matched_connections =
          connections_map[k2]
          |> Enum.filter(fn k3 -> k1 in connections_map[k3] end)
          |> Enum.map(fn k3 -> Enum.sort([k1, k2, k3]) end)

        matched_connections ++ acc
      end)
      |> Enum.uniq()
      |> Enum.sort()
    end)
    |> Enum.uniq()
    |> Enum.filter(fn lan ->
      Enum.any?(lan, &String.starts_with?(&1, "t"))
    end)
    |> length()
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(%{}, fn str, acc ->
      [a, b] = String.split(str, "-")

      acc
      |> Map.update(a, [b], fn v -> [b | v] end)
      |> Map.update(b, [a], fn v -> [a | v] end)
    end)
  end

  def read_the_input(path), do: File.read!(path)
end
