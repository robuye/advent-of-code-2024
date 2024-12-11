defmodule Day11 do
  def find_the_answer_p1() do
    "data/day_11.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    blink_times = 25

    1..blink_times
    |> Enum.reduce(input, fn _i, acc ->
      Enum.flat_map(acc, &blink_once/1)
    end)
  end

  def blink_once("0"), do: ["1"]

  def blink_once(n) when rem(byte_size(n), 2) == 0 do
    half = div(String.length(n), 2)

    [lhs, rhs] =
      n
      |> String.graphemes()
      |> Enum.chunk_every(half)

    rhs
    |> Enum.reduce({lhs, []}, fn
      "0", {a, b} when b == [] -> {a, b}
      chr, {a, b} -> {a, b ++ [chr]}
    end)
    |> case do
      {a, []} -> [Enum.join(a), "0"]
      {a, b} -> [Enum.join(a), Enum.join(b)]
    end
  end

  def blink_once(str) do
    (String.to_integer(str) * 2024)
    |> to_string()
    |> List.wrap()
  end

  def parse(input) do
    input
    |> String.trim()
    |> String.split(" ")
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
