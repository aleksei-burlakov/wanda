defmodule WandaWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use WandaWeb, :controller
      use WandaWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

    
  {:ok, file} = File.open("wanda.stacktrace", [:append])
  IO.binwrite(file, "*** WandaWeb.CLASS_INITIALISATION ***\n")
  IO.binwrite(file, Exception.format_stacktrace())
  File.close(file)
    
  def controller do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** controller ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    quote do
      use Phoenix.Controller, namespace: WandaWeb

      import Plug.Conn
      alias WandaWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** view ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    quote do
      use Phoenix.View,
        root: "lib/wanda_web/templates",
        namespace: WandaWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_flash: 1, get_flash: 2, view_module: 1, view_template: 1]

      # Include shared imports and aliases for views
      unquote(view_helpers())
    end
  end

  def router do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** router ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
    end
  end

  def channel do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** channel ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    quote do
      use Phoenix.Channel
    end
  end

  defp view_helpers do
    
    {:ok, file} = File.open("wanda.stacktrace", [:append])
    IO.binwrite(file, "*** view_helpers ***\n")
    IO.binwrite(file, Exception.format_stacktrace())
    File.close(file)
    
    quote do
      # Import basic rendering functionality (render, render_layout, etc)
      import Phoenix.View

      alias WandaWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
