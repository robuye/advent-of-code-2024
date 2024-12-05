defmodule Day05 do
  def find_the_answer_p1() do
    "data/day_05.txt"
    |> read_the_input()
    |> parse()
    |> split_pages()
    |> play_the_game_p1()
  end

  def find_the_answer_p2() do
    "data/day_05.txt"
    |> read_the_input()
    |> parse()
    |> split_pages()
    |> play_the_game_p2()
  end

  def play_the_game_p1(state) do
    state.valid_pages
    |> Enum.map(fn pages ->
      Enum.at(pages, trunc(length(pages) / 2))
    end)
    |> Enum.sum()
  end

  def play_the_game_p2(state) do
    state.invalid_pages
    |> Enum.map(fn pages ->
      matching_rules =
        state.rules
        |> Enum.filter(fn {a, b} ->
          Enum.member?(pages, a) and Enum.member?(pages, b)
        end)

      fix_pages_ordering(pages, matching_rules)
    end)
    |> Enum.map(fn pages ->
      Enum.at(pages, trunc(length(pages) / 2))
    end)
    |> Enum.sum()
  end

  def fix_pages_ordering(pages, rules) do
    rules
    |> Enum.reduce(pages, fn {a, b}, acc ->
      position_a = Enum.find_index(acc, &(&1 == a))
      position_b = Enum.find_index(acc, &(&1 == b))

      if position_a < position_b do
        acc
      else
        value_at_a = Enum.at(acc, position_a)
        value_at_b = Enum.at(acc, position_b)

        acc
        |> List.replace_at(position_a, value_at_b)
        |> List.replace_at(position_b, value_at_a)
        |> fix_pages_ordering(rules)
      end
    end)
  end

  def split_pages(state) do
    state.input
    |> Enum.reduce(state, fn pages, acc ->
      matching_rules =
        state.rules
        |> Enum.filter(fn {a, b} ->
          Enum.member?(pages, a) and Enum.member?(pages, b)
        end)

      is_ok =
        Enum.all?(matching_rules, fn {a, b} ->
          position_a = Enum.find_index(pages, &(&1 == a))
          position_b = Enum.find_index(pages, &(&1 == b))

          position_a < position_b
        end)

      if is_ok do
        Map.update!(acc, :valid_pages, &(&1 ++ [pages]))
      else
        Map.update!(acc, :invalid_pages, &(&1 ++ [pages]))
      end
    end)
  end

  def parse(input) do
    initial_state = %{
      rules: [],
      input: [],
      valid_pages: [],
      invalid_pages: []
    }

    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(initial_state, fn line, acc ->
      cond do
        String.contains?(line, "|") ->
          [a, b] = String.split(line, "|")
          rule = {String.to_integer(a), String.to_integer(b)}
          Map.update!(acc, :rules, &(&1 ++ [rule]))

        String.contains?(line, ",") ->
          nums =
            String.split(line, ",", trim: true)
            |> Enum.map(&String.to_integer/1)

          Map.update!(acc, :input, &(&1 ++ [nums]))

        true ->
          acc
      end
    end)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
