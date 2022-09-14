defmodule MTKitchen.Error.ServiceUnavailableError do
  defexception [:message]

  def exception(opts) do
    msg = opts[:message] || "Service is currently unavailable. Please try again later."

    %__MODULE__{message: msg}
  end
end

defmodule MTKitchen.Error.ResourceNotFoundError do
  defexception [:message]

  def exception(opts) do
    msg = opts[:message] || "Resource was not found or is not publicly accessible."

    %__MODULE__{message: msg}
  end
end

plug_errors = [
  {MTKitchen.Error.ResourceNotFoundError, 404},
  {MTKitchen.Error.ServiceUnavailableError, 503}
]

for {exception, status_code} <- plug_errors do
  defimpl Plug.Exception, for: exception do
    def status(_), do: unquote(status_code)
    def actions(_), do: []
  end
end
