defmodule LibraryWeb.BooksLive do
  use LibraryWeb, :live_view

  alias Library.Books
  alias Library.Books.Book

  def render(assigns) do
    case assigns[:action] do
      :show -> local_show(assigns)
      :new -> local_new(assigns)
      :edit -> local_edit(assigns)
      _ -> index(assigns)
    end
  end

  def mount(_params, _session, socket) do
    {:ok, socket
      |> assign(:action, :index)
      |> assign(:books, Books.list_books())
      |> assign(:title_order, %{phx_click: "sort_by_title_asc", order_by: :asc})
      |> assign(:uploaded_files, [])
      |> allow_upload(:photo, accept: ~w(.jpg .jpeg .png), max_entries: 1)
    }
  end

  def handle_event("sort_by_title_asc", _params, socket) do
    {:noreply,
      socket
      |> update(:books, &Books.order_books_by_title(&1, :asc))
      |> assign(:title_order, %{phx_click: "sort_by_title_desc", order_by: :desc})
    }
  end

  def handle_event("sort_by_title_desc", _params, socket) do
    {:noreply,
      socket
      |> update(:books, &Books.order_books_by_title(&1, :desc))
      |> assign(:title_order, %{phx_click: "sort_by_title_asc", order_by: :asc})
    }
  end

  def handle_event("show", %{"id" => id}, socket) do
    book = Books.get_book!(String.to_integer(id))
    {:noreply,
      socket
      |> assign(:action, :show)
      |> assign(:book, book)
    }
  end

  def handle_event("delete", %{"id" => id}, socket) do
    deleted_book = Books.get_book!(String.to_integer(id))
    Books.delete_book(deleted_book)
    {:noreply,
      socket
      |> update(:books, &Enum.reject(&1, fn book -> book == deleted_book end))
    }
  end

  def handle_event("new", _params, socket) do
    changeset = Books.change_book(%Book{})
    {:noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:action, :new)
    }
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", params, socket) do
    book_params = params["book"]
    new_book_params = new_book_params(socket, book_params)

    action = case params["action"] do
      "edit" ->
        book = Books.get_book!(String.to_integer(params["id"]))
        Books.update_book(book, new_book_params)
      _ -> Books.create_book(new_book_params)
    end

    case action do
      {:ok, book} ->
        {:noreply, socket
          |> assign(:action, :show)
          |> assign(:book, book)
        }

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket
          |> assign(:action, :new)
          |> assign(:changeset, changeset)
        }
    end
  end

  def handle_event("edit", %{"id" => id}, socket) do
    book = Books.get_book!(String.to_integer(id))
    {:noreply,
      socket
      |> assign(:action, :edit)
      |> assign(:book, book)
      |> assign(:changeset, Books.change_book(book))
    }
  end

  defp new_book_params(socket, book_params) do
    uploaded_files =
      consume_uploaded_entries(socket, :photo, fn %{path: path}, _entry ->
        dest = Path.join(Application.app_dir(:library, "priv/static/images/cover_images"), Path.basename(path))
        File.cp!(path, dest)
        {:ok, ~p"/images/cover_images/#{Path.basename(dest)}"}
      end)

    new_book_params = Map.merge(book_params, %{"cover_image_path" => Enum.at(uploaded_files, 0)})
    Map.update!(new_book_params, "publisher_id", fn publisher_id -> String.to_integer(publisher_id) end)
  end

  defp index(assigns) do
    ~H"""
    <.header>
      Listing Books
      <:actions>
        <.link>
          <.button phx-click="new">New Book </.button>
        </.link>

        <.simple_form :let={f} for={%{}} phx-change="validate" phx-submit="save" >
          <.input class="form-control me-2" id="book-search-field-0" type="search" placeholder="Search" aria-label="Search" name="search" value=""/>
        </.simple_form>

        <.button phx-click={ @title_order[:phx_click] } >Sort title <%= to_string(@title_order[:order_by]) %></.button>
      </:actions>
    </.header>

    <.table id="books" rows={@books}}>
      <:col :let={book} label="Title"><%= book.title %></:col>
      <:col :let={book} label="Isbn"><%= book.isbn %></:col>
      <:col :let={book} label="Publisher"><%= book.publisher.name %></:col>
      <:action :let={book}>
        <.link phx-click="show" phx-value-id={book.id}>Show</.link>
      </:action>
      <:action :let={book}>
        <div class="sr-only">
          <.link phx-click="show" phx-value-id={book.id}>Show</.link>
        </div>
        <.link phx-click="edit" phx-value-id={book.id}>Edit</.link>
      </:action>
      <:action :let={book}>
        <.link phx-click="delete" phx-value-id={book.id}>Delete</.link>
      </:action>
    </.table>
    """
  end

  defp local_show(assigns) do
    ~H"""
      <.header>
        Book <%= @book.id %>
        <:subtitle>This is a book record from your database.</:subtitle>
        <:actions>
          <.link phx-click="edit" phx-value-id={@book.id}>Edit</.link>
        </:actions>
      </.header>

      <img src={cover_path(@book)} />

      <.list>
        <:item title="Title"><%= @book.title %></:item>
        <:item title="Isbn"><%= @book.isbn %></:item>
        <:item title="Cover image path"><%= @book.cover_image_path %></:item>

        <:item title="Publisher">
          <.link href={~p"/publishers/#{@book}"}>
            <%= @book.publisher.name %>
          </.link>
        </:item>
      </.list>

      <.back navigate={~p"/books_live"}>Back to books</.back>
    """
  end

  defp cover_path(%Library.Books.Book{} = book) do
    String.replace(book.cover_image_path, "priv/static", "")
  end

  defp local_new(assigns) do
    ~H"""
      <.header>
        New Book
        <:subtitle>Use this form to manage book records in your database.</:subtitle>
      </.header>

      <%= book_form(assigns, "new") %>

      <.back navigate={~p"/books_live"}>Back to books</.back>
    """
  end

  defp publisher_opts(changeset) do
    existing_ids =
      changeset
      |> Ecto.Changeset.get_change(:publisher_ids, [])
      |> Enum.map(& &1.data.id)

    for publisher <- Library.Editorial.list_publishers(),
      do: [key: publisher.name, value: publisher.id, selected: publisher.id in existing_ids]
  end

  defp local_edit(assigns) do
    ~H"""
      <.header>
        Edit Book <%= @book.id %>
        <:subtitle>Use this form to manage book records in your database.</:subtitle>
      </.header>

      <%= book_form(assigns, "edit", @book.id) %>

      <.back navigate={~p"/books_live"}>Back to books</.back>
    """
  end

  defp book_form(assigns, action, id \\ nil) do
    ~H"""
      <.simple_form :let={f} for={@changeset} phx-change="validate" phx-submit="save"
        phx-value-id={id} phx-value-action={action} multipart>
        <.error :if={@changeset.action}>
          Oops, something went wrong! Please check the errors below.
        </.error>
        <.input field={f[:title]} type="text" label="Title" />
        <.input field={f[:isbn]} type="text" label="Isbn" />
        <.live_file_input upload={@uploads.photo} />
        <.input field={f[:publisher_id]} type="select" options={publisher_opts(@changeset)} />
        <.button>Save Book</.button>
      </.simple_form>
    """
  end
end
