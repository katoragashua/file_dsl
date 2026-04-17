defmodule FileDSL do
  defmacro __using__(_options) do
    quote do
      import unquote(__MODULE__)
      Module.register_attribute(__MODULE__, :file_actions, accumulate: true)

      # This will call the __before_compile__ macro before the module is compiled, allowing us to inject the handle_file function into the module that uses MyFile.
      @before_compile unquote(__MODULE__)
    end
  end

  # This macro will be called before the module that uses MyFile is compiled, allowing us to inject the handle_file function into that module.
  defmacro __before_compile__(_env) do
    quote do
      def handle_file(file_path, flag, text \\ nil) do
        # IO.inspect(@file_actions)
        desired_action =
          Enum.find(@file_actions, nil, fn {_, action_flag, _} -> flag == action_flag end)

        # Other ways to find the desired action:
        #  desired_action = Enum.find_value(@file_actions, nil, fn {_, action_flag, action_func} -> if flag == action_flag, do: action_func, else: nil end)
        # desired_action =
        # Enum.find_value(@file_actions, fn {_, action_flag, action_func} ->
        #   flag == action_flag && action_func
        # end) || nil

        case desired_action do
          # {_action_name, action_flag, action_func} when action_flag == :r or action_flag == :d -> apply(__MODULE__, action_func, [file_path])
          {_action_name, action_flag, action_func} when action_flag in [:r, :d] ->
            apply(__MODULE__, action_func, [file_path])

          {_action_name, _action_flag, action_func} ->
            # Read user input from the console if text is not provided
            text =
              if text == nil, do: IO.gets(:stdio, "Enter text: ") |> String.trim(), else: text

            apply(__MODULE__, action_func, [file_path, text])

          nil ->
            {:error, "Invalid action flag: #{flag}"}
        end
      end
    end
  end

  defmacro file_action(action_name, action_flag, action_func) do
    quote do: @file_actions({unquote(action_name), unquote(action_flag), unquote(action_func)})
  end
end
