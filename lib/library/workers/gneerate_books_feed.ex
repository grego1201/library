defmodule Library.Workers.GenerateBooksFeed do
  use Oban.Worker, queue: :default

  alias Library.Doofinder

  @impl Oban.Worker
  def perform(_job) do
    Doofinder.generate_books_feed()
    :ok
  end
end
