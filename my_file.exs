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
      def run_file_actions(file_path) do
        # Enum.each(@file_actions, fn {action, file_path} ->
        #   apply(File, action, [file_path])
        # end)
        IO.inspect({@file_actions})
      end
    end
  end

  defmacro file_action(action_name, action) do
    quote do: @file_actions {unquote(action_name), unquote(action)}
  end
end


defmodule FileSystem do
  use MyFile

  file_action :read, :read_file
  file_action :write, :write_file

  def read_file (file_path) do
    IO.puts("Reading from #{file_path}")
  end

  def write_file(file_path) do
    IO.puts("Writing to #{file_path}")
  end

end
