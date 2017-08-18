# Exbug

A more traditional experience for the :debugger module

## Installation

by adding `exbug` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:exbug, "~> 0.0.1", only: :dev}]
end
```

Documentation found at [https://hexdocs.pm/exbug](https://hexdocs.pm/exbug).


# Explanation
Provides a traditional debugging experince for Elixir
by providing a thin layer around the :debugger & :int modules.
To be used with `iex -S mix`.


# How it works
Be warned, this is more of a hack than anything. I feel pretty dirty about
it, but here we go.


## Background
the `iex` shell is a great tool. It's so great, it can event be customised
with a `.iex.exs` file. `IEx` will load this file if it's present in the
directory in which `iex` is run.


## iex.exs hack
`Exbug.__using__/1` appends your `.iex.exs` file with the code needed to
* Start the Erlang graphical debugger
* Mark the hosting module for debugging


## `debug/0`
Next, to set a breakpoint you must use the `debug/0` function. It marks sets
a breakpoint on the same line the `debug()` statement is on. I'm sorry for
the next part.


Next, it uses `:timer.sleep/1` to sleep the calling process until the
:debugger and :int module have time to catch up to the calling process.


## Why would you do that?!
As you would suspect, the :debugger & :int modules runs in a different
process to the calling module. If you _don't_ sleep the calling process,
the code will continue executing and the breakpoint won't be set in time.


Please don't use this in production.


## What about my existing .iex.exs file?
Exbug uses deliminters to denote any appended code. The `@on_load` attribute
is used so that when the `Exbug` module is loaded, and previously appended
Exbug code is cleaned out and removed


# Examples
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
