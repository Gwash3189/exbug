defmodule Exbug do
  @regex ~r/#EXBUG START(?s)(.*)#EXBUG STOP/
  @on_load :clean
  @moduledoc """
    Provides a traditional debugging experince for Elixir
    by providing a thin layer around the :debugger & :int modules.
    To be used with `iex -S mix`.


    **How it works**


    Be warned, this is more of a hack than anything. I feel pretty dirty about
    it, but here we go.


    **Background**


    the `iex` shell is a great tool. It's so great, it can event be customised
    with a `.iex.exs` file. `IEx` will load this file if it's present in the
    directory in which `iex` is run.


    **iex.exs hack**


    `Exbug.__using__/1` appends your `.iex.exs` file with the code needed to
    start the Erlang graphical debugger and mark the hosting module for
    debugging


    **`debug/0`**


    Next, to set a breakpoint you must use the `debug/0` function. It marks sets
    a breakpoint on the same line the `debug()` statement is on. I'm sorry for
    the next part.


    Next, it uses `:timer.sleep/1` to sleep the calling process until the
    :debugger and :int module have time to catch up to the calling process.


    **Why would you do that?!**


    As you would suspect, the :debugger & :int modules runs in a different
    process to the calling module. If you _don't_ sleep the calling process,
    the code will continue executing and the breakpoint won't be set in time.


    Please don't use this in production.


    **What about my existing .iex.exs file?**


    Exbug uses deliminters to denote any appended code. The `@on_load` attribute
    is used so that when the `Exbug` module is loaded, and previously appended
    Exbug code is cleaned out and removed


    **Example**
    ```
      # controller.ex
      defmodule Controller do
        use Exbug

        def show(conn, _) do
            debug()
            # ...
        end
      end
    ```


    ```
      > mix compile --force && iex -S mix
      ...
      iex> Controller.show(conn, nil)
      # debugger is started and breakpoint is hit
    ```
  """

  @doc """
    Path to the projects .iex.exs file
  """
  def dot_iex_path do
    Path.join([File.cwd!, ".iex.exs"])
  end

  @doc """
    Writes the provided contents to the projects .iex.exs file
  """
  def write_to_dot_iex(contents, file \\ File) do
    file.write(Exbug.dot_iex_path(), contents, [:append])
  end

  def dot_iex_content(module) do
    """
    #EXBUG START
    :debugger.start(:local)
    :int.ni(#{module})
    #EXBUG STOP
    """
  end

  @doc """
    Cleans the .iex.exs file of all exbug statments
  """
  def clean(file \\ File) do
    case file.read(dot_iex_path()) do
      {:ok, contents} ->
        contents = Regex.replace(@regex, contents, "")
        contents = String.trim(contents)
        File.write!(dot_iex_path(), contents)
      {:error, _} -> :ok
    end
  end

  @doc """
    Starts a debugger with the requested line and module marked for debugging
  """
  defmacro __using__(_) do
    quote do
      import Exbug
      __MODULE__
      |> dot_iex_content
      |> write_to_dot_iex
    end
  end

  @doc """
    adds a breakpoint
  """
  defmacro debug do
    quote do
      line = Macro.Env.location(__ENV__) |> Keyword.get(:line)
      :int.break(__MODULE__, line)
      :timer.sleep(1)
    end
  end
end
