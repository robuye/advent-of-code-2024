defmodule Day14 do
  def find_the_answer_p1() do
    "data/day_14.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p1()
  end

  def find_the_answer_p2() do
    "data/day_14.txt"
    |> read_the_input()
    |> parse()
    |> play_the_game_p2()
  end

  def play_the_game_p1(robots) do
    {width, height} = {101, 103}

    robots
    |> Enum.with_index()
    |> Enum.map(fn {robot, _i} ->
      1..100
      |> Enum.reduce(robot, fn _i, robot ->
        make_a_move(robot, %{width: width, height: height})
      end)
    end)
    |> Enum.map(& &1.position)
    |> Enum.reject(fn %{x: x, y: y} -> x == (width - 1) / 2 or y == (height - 1) / 2 end)
    |> Enum.group_by(fn robot ->
      q_left = robot.x < width / 2
      q_right = robot.x > width / 2
      q_up = robot.y < height / 2
      q_down = robot.y > height / 2

      cond do
        q_left and q_up -> 0
        q_right and q_up -> 1
        q_right and q_down -> 2
        q_left and q_down -> 3
      end
    end)
    |> Enum.map(fn {_q, robots} -> length(robots) end)
    |> Enum.product()
  end

  def play_the_game_p2(robots) do
    {width, height} = {101, 103}

    1..10_000
    |> Enum.reduce_while(robots, fn i, robots ->
      new_robots =
        robots
        |> Enum.map(fn robot ->
          make_a_move(robot, %{width: width, height: height})
        end)

      if look_for_christmas_tree(new_robots) do
        IO.puts("Found a christmas tree in move #{i}")
        print_board(new_robots)
        {:halt, new_robots}
      else
        {:cont, new_robots}
      end
    end)

    true
  end

  def look_for_christmas_tree(robots) do
    robots = Enum.map(robots, & &1.position)

    lines =
      1..100
      |> Enum.map(fn y ->
        1..100
        |> Enum.reduce("", fn x, acc ->
          if %{x: x, y: y} in robots do
            acc <> "#"
          else
            acc <> " "
          end
        end)
      end)

    lines
    |> Enum.any?(&String.contains?(&1, "##########"))
  end

  def print_board(robots) do
    robots = Enum.map(robots, & &1.position)

    1..100
    |> Enum.map(fn y ->
      1..100
      |> Enum.reduce("", fn x, acc ->
        if %{x: x, y: y} in robots do
          acc <> "#"
        else
          acc <> " "
        end
      end)
    end)
    |> Enum.each(&IO.puts/1)

    IO.puts("")

    :ok
  end

  def make_a_move(robot, opts) do
    new_x =
      (robot.position.x + robot.velocity.x)
      |> case do
        x when x < 0 -> opts.width + x
        x when x > opts.width - 1 -> x - opts.width
        x -> x
      end

    new_y =
      (robot.position.y + robot.velocity.y)
      |> case do
        y when y < 0 -> opts.height + y
        y when y > opts.height - 1 -> y - opts.height
        y -> y
      end

    %{robot | position: %{x: new_x, y: new_y}}
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [p_str, v_str] = String.split(line, " ", trim: true)

      [[px_str], [py_str]] = Regex.scan(~r/\d+/, p_str)
      [[vx_str], [vy_str]] = Regex.scan(~r(-?\d+), v_str)

      %{
        position: %{x: String.to_integer(px_str), y: String.to_integer(py_str)},
        velocity: %{x: String.to_integer(vx_str), y: String.to_integer(vy_str)}
      }
    end)
  end

  def read_the_input(path) do
    path
    |> File.read!()
  end
end
