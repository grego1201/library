defmodule LibraryWeb.BookLive.FormComponent do
  use LibraryWeb, :live_component

  alias Library.Books

  @impl true
  def render(assigns) do
    assigns = assign(assigns, :changeset, Books.change_book(assigns[:book]))
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage book records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="book-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:isbn]} type="text" label="Isbn" />
        <.live_file_input upload={@uploads.photo} />
        <.input field={@form[:publisher_id]} type="select" options={publisher_opts(@changeset)} />

        <:actions>
          <.button phx-disable-with="Saving...">Save Book</.button>
        </:actions>
      </.simple_form>
    </div>
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

  @impl true
  def update(%{book: book} = assigns, socket) do
    changeset = Books.change_book(book)

    {:ok,
     socket
      |> assign(:uploaded_files, [%{path: book.cover_image_path}])
      |> allow_upload(:photo, accept: ~w(.jpg .jpeg .png), max_entries: 1)
      |> assign(assigns)
      |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"book" => book_params}, socket) do
    changeset =
      socket.assigns.book
      |> Books.change_book(book_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"book" => book_params}, socket) do
    save_book(socket, socket.assigns.action, new_book_params(socket, book_params))
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

  defp save_book(socket, :edit, book_params) do
    book_params = if book_params["cover_image_path"] == nil do
      Map.merge(book_params, %{"cover_image_path" => socket.assigns.book.cover_image_path})
    else
      book_params
    end

    case Books.update_book(socket.assigns.book, book_params) do
      {:ok, book} ->
        notify_parent({:saved, book})

        {:noreply,
         socket
         |> put_flash(:info, "Book updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_book(socket, :new, book_params) do
    case Books.create_book(book_params) do
      {:ok, book} ->
        notify_parent({:saved, book})

        {:noreply,
         socket
         |> put_flash(:info, "Book created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
