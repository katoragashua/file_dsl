defmodule MyFile do

  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :file_actions, accumulate: true)

      @before_compile unquote(__MODULE__)
    end
  end

  defmacro __before_compile__(_env) do
    quote do
      def run_file_actions(file_path, action) do
        IO.inspect(@file_actions)
          desired_action = Enum.find(@file_actions, nil, fn {action_name, _} -> action_name == action end)
          IO.inspect(desired_action)

          case desired_action do
            {action_name, action_func} -> apply(__MODULE__, action_func, [file_path])
            nil -> IO.puts("Action #{action} not found.")
          end

      end
    end
  end

  defmacro file_action(action_name, action_func) do
    quote do: @file_actions {unquote(action_name), unquote(action_func)}
  end
end


defmodule FileSystem do
  use MyFile

  file_action :read, :read_file
  file_action :write, :write_file
  file_action :append, :append_file

  def read_file (file_path) do
    IO.puts("Reading from #{file_path}")
  end

  def write_file(file_path) do
    IO.puts("Writing to #{file_path}")
  end

end
