defmodule Day07 do
  def find_the_answer_p1() do
    "data/day_07.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def find_the_answer_p2() do
    "data/day_07.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p2()
  end

  def play_the_game_p2(input) do
    input
    |> Enum.map(fn state ->
      %{
        test_value: state.test_value,
        instructions:
          state.numbers
          |> Enum.flat_map(&[&1, :op])
          |> List.delete_at(-1)
          |> transform_operations([:add, :mult, :concat])
      }
    end)
    |> Enum.filter(fn state ->
      state.instructions
      |> Enum.any?(&(run_instructions(&1) == state.test_value))
    end)
    |> Enum.map(& &1.test_value)
    |> Enum.sum()
  end

  def play_the_game_p1(input) do
    input
    |> Enum.map(fn state ->
      %{
        test_value: state.test_value,
        instructions:
          state.numbers
          |> Enum.flat_map(&[&1, :op])
          |> List.delete_at(-1)
          |> transform_operations([:add, :mult])
      }
    end)
    |> Enum.filter(fn state ->
      state.instructions
      |> Enum.any?(&(run_instructions(&1) == state.test_value))
    end)
    |> Enum.map(& &1.test_value)
    |> Enum.sum()
  end

  def transform_operations(instructions, ops) do
    # [81, :op, 40, :op, 27]
    ops_count = Enum.count(instructions, &(&1 == :op))
    variants_count = round(:math.pow(length(ops), ops_count)) - 1

    0..variants_count
    |> Enum.map(fn variant_index ->
      {replacements_list, _} =
        Enum.reduce(0..(ops_count - 1), {[], 0}, fn _, {acc, idx} ->
          replacement_index = rem(idx + variant_index, length(ops))
          new_index = div(idx + variant_index, length(ops))
          {[Enum.at(ops, replacement_index) | acc], new_index}
        end)

      {result, _} =
        instructions
        |> Enum.reduce({[], replacements_list}, fn step, {result, replacements} ->
          if step == :op do
            {op, new_replacements} = List.pop_at(replacements, 0)
            {[op | result], new_replacements}
          else
            {[step | result], replacements}
          end
        end)

      result
      |> Enum.reverse()
    end)
  end

  def run_instructions(instructions) do
    # [81, :add, 40, :mult, 27]
    instructions
    |> Enum.reduce({0, :add}, fn
      val, {total, current_op} when is_number(val) ->
        new_total =
          case current_op do
            :add -> total + val
            :mult -> total * val
            :concat -> String.to_integer("#{total}#{val}")
          end

        {new_total, current_op}

      new_op, {total, _op} ->
        {total, new_op}
    end)
    |> elem(0)
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [test_value_str, numbers_str] = String.split(line, ":")

      test_value = String.to_integer(test_value_str)

      numbers =
        numbers_str
        |> String.split(" ", trim: true)
        |> Enum.map(fn num_str -> String.to_integer(num_str) end)

      %{test_value: test_value, numbers: numbers}
    end)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
