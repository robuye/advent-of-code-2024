defmodule Day22 do
  def find_the_answer_p1() do
    "data/day_22.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def play_the_game_p1(input) do
    input
    |> Enum.map(fn initial_secret ->
      {initial_secret, derive_secret(initial_secret, 2000)}
    end)
    |> Enum.into(%{})
    |> Enum.reduce(0, fn {_initial, result}, acc -> acc + result end)
  end

  def derive_secret(secret, 0), do: secret

  def derive_secret(secret, n) do
    secret =
      (secret * 64)
      |> mix(secret)
      |> prune()

    secret =
      div(secret, 32)
      |> mix(secret)
      |> prune()

    secret =
      (secret * 2048)
      |> mix(secret)
      |> prune()

    derive_secret(secret, n - 1)
  end

  def mix(a, b), do: Bitwise.bxor(a, b)

  def prune(x), do: Integer.mod(x, 16_777_216)

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
