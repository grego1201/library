defmodule LibraryWeb.BookLive.Index do
  use LibraryWeb, :live_view

  alias Library.Books
  alias Library.Books.Book

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:title_order, %{phx_click: "sort_by_title_asc", order_by: :asc})
      |> stream(:books, Books.list_books())
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Book")
    |> assign(:book, Books.get_book!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Book")
    |> assign(:book, %Book{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Books")
    |> assign(:book, nil)
  end

  @impl true
  def handle_info({LibraryWeb.BookLive.FormComponent, {:saved, book}}, socket) do
    {:noreply, stream_insert(socket, :books, book)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    book = Books.get_book!(id)
    {:ok, _} = Books.delete_book(book)

    {:noreply, stream_delete(socket, :books, book)}
  end

  def handle_event("sort_by_title_asc", _params, socket) do
    {:noreply,
      socket
      |> stream(:books, Books.order_books_by_title(:asc), reset: true)
      |> assign(:title_order, %{phx_click: "sort_by_title_desc", order_by: :desc})
    }
  end

  def handle_event("sort_by_title_desc", _params, socket) do
    {:noreply, socket
      |> stream(:books, Books.order_books_by_title(:desc), reset: true)
      |> assign(:title_order, %{phx_click: "sort_by_title_asc", order_by: :asc})
    }
  end
end
