defmodule LibraryWeb.PublisherControllerTest do
  use LibraryWeb.ConnCase

  import Library.EditorialFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  describe "index" do
    test "lists all publishers", %{conn: conn} do
      conn = get(conn, ~p"/publishers")
      assert html_response(conn, 200) =~ "Listing Publishers"
    end
  end

  describe "new publisher" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/publishers/new")
      assert html_response(conn, 200) =~ "New Publisher"
    end
  end

  describe "create publisher" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/publishers", publisher: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/publishers/#{id}"

      conn = get(conn, ~p"/publishers/#{id}")
      assert html_response(conn, 200) =~ "Publisher #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/publishers", publisher: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Publisher"
    end
  end

  describe "edit publisher" do
    setup [:create_publisher]

    test "renders form for editing chosen publisher", %{conn: conn, publisher: publisher} do
      conn = get(conn, ~p"/publishers/#{publisher}/edit")
      assert html_response(conn, 200) =~ "Edit Publisher"
    end
  end

  describe "update publisher" do
    setup [:create_publisher]

    test "redirects when data is valid", %{conn: conn, publisher: publisher} do
      conn = put(conn, ~p"/publishers/#{publisher}", publisher: @update_attrs)
      assert redirected_to(conn) == ~p"/publishers/#{publisher}"

      conn = get(conn, ~p"/publishers/#{publisher}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, publisher: publisher} do
      conn = put(conn, ~p"/publishers/#{publisher}", publisher: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Publisher"
    end
  end

  describe "delete publisher" do
    setup [:create_publisher]

    test "deletes chosen publisher", %{conn: conn, publisher: publisher} do
      conn = delete(conn, ~p"/publishers/#{publisher}")
      assert redirected_to(conn) == ~p"/publishers"

      assert_error_sent 404, fn ->
        get(conn, ~p"/publishers/#{publisher}")
      end
    end
  end

  defp create_publisher(_) do
    publisher = publisher_fixture()
    %{publisher: publisher}
  end
end
