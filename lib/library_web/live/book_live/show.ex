defmodule LibraryWeb.BookLive.Show do
  use LibraryWeb, :live_view

  alias Library.Books

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:uploaded_files, [])
      |> allow_upload(:photo, accept: ~w(.jpg .jpeg .png), max_entries: 1)
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply, socket
      |> assign(:page_title, page_title(socket.assigns.live_action))
      |> assign(:book, Books.get_book!(id))
    }
  end

  defp page_title(:show), do: "Show Book"
  defp page_title(:edit), do: "Edit Book"

  defp cover_path(%Library.Books.Book{} = book) do
    String.replace(book.cover_image_path, "priv/static", "")
  end
end
