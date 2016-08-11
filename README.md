# Queue

A basic queue (akin to Ruby's Delayed Job) for Elixir.

Inspired by José Valim's London 2016 presentation introducing GenStage.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `queue` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:queue, "~> 0.1.0"}]
    end
    ```

  2. Ensure `queue` is started before your application:

    ```elixir
    def application do
      [applications: [:queue]]
    end
    ```

## Usage

```elixir
Queue.enqueue IO, :puts, ["hello world!"]
```
