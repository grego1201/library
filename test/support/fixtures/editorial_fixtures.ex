defmodule Library.EditorialFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Library.Editorial` context.
  """

  @doc """
  Generate a publisher.
  """
  def publisher_fixture(attrs \\ %{}) do
    {:ok, publisher} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Library.Editorial.create_publisher()

    publisher
  end
end
