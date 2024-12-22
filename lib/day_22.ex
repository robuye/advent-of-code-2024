defmodule Day22 do
  def find_the_answer_p1() do
    "data/day_22.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def find_the_answer_p2() do
    "data/day_22.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p2()
  end

  def play_the_game_p1(input) do
    input
    |> Enum.map(fn initial_secret ->
      {initial_secret, derive_secret(initial_secret, 2000)}
    end)
    |> Enum.into(%{})
    |> Enum.reduce(0, fn {_initial, result}, acc -> acc + result end)
  end

  def play_the_game_p2(input) do
    monkeys =
      input
      |> Enum.map(fn initial_secret ->
        price_history =
          [initial_secret | derive_secrets(initial_secret, 2000, [])]
          |> Enum.map(&Integer.mod(&1, 10))

        price_history
        |> Enum.with_index()
        |> Enum.map(fn {price_now, i} ->
          sequence =
            if i > 3 do
              Enum.slice(price_history, i - 3, 4)
              |> Enum.with_index()
              |> Enum.map(fn {price_then, j} ->
                prev_price = if(i - 4 + j > 0, do: Enum.at(price_history, i - 4 + j))
                if(prev_price, do: price_then - prev_price)
              end)
            else
              [nil, nil, nil, nil]
            end

          {price_now, sequence}
        end)
        |> Enum.filter(fn {_, sequence} -> Enum.all?(sequence) end)
        |> Enum.map(fn {price, sequence} -> {sequence, price} end)
        |> Enum.uniq_by(fn {sequence, _} -> sequence end)
        |> Enum.into(%{})
      end)

    # => [[%{seq => price}, ...], ...]

    # check every possible sequence among all monkeys
    monkeys
    |> Enum.flat_map(&Map.keys/1)
    |> Enum.uniq()
    |> Enum.reduce(0, fn seq, acc ->
      total =
        monkeys
        |> Enum.map(fn that_monkey_prices -> that_monkey_prices[seq] || 0 end)
        |> Enum.sum()

      if(total > acc, do: total, else: acc)
    end)
  end

  def derive_secrets(_secret, 0, acc), do: Enum.reverse(acc)

  def derive_secrets(secret, n, acc) do
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

    derive_secrets(secret, n - 1, [secret | acc])
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
