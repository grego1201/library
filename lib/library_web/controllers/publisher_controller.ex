defmodule LibraryWeb.PublisherController do
  use LibraryWeb, :controller

  alias Library.Editorial
  alias Library.Editorial.Publisher

  def index(conn, _params) do
    publishers = Editorial.list_publishers()
    render(conn, :index, publishers: publishers)
  end

  def new(conn, _params) do
    changeset = Editorial.change_publisher(%Publisher{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"publisher" => publisher_params}) do
    case Editorial.create_publisher(publisher_params) do
      {:ok, publisher} ->
        conn
        |> put_flash(:info, "Publisher created successfully.")
        |> redirect(to: ~p"/publishers/#{publisher}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    publisher = Editorial.get_publisher!(id)
    render(conn, :show, publisher: publisher)
  end

  def edit(conn, %{"id" => id}) do
    publisher = Editorial.get_publisher!(id)
    changeset = Editorial.change_publisher(publisher)
    render(conn, :edit, publisher: publisher, changeset: changeset)
  end

  def update(conn, %{"id" => id, "publisher" => publisher_params}) do
    publisher = Editorial.get_publisher!(id)

    case Editorial.update_publisher(publisher, publisher_params) do
      {:ok, publisher} ->
        conn
        |> put_flash(:info, "Publisher updated successfully.")
        |> redirect(to: ~p"/publishers/#{publisher}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, publisher: publisher, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    publisher = Editorial.get_publisher!(id)
    {:ok, _publisher} = Editorial.delete_publisher(publisher)

    conn
    |> put_flash(:info, "Publisher deleted successfully.")
    |> redirect(to: ~p"/publishers")
  end
end
