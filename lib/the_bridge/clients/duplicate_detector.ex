defmodule TheBridge.Clients.DuplicateDetector do
  @moduledoc """
  Advisory duplicate detection for clients.
  Matches on initials + birth_year (exact and fuzzy ±1 year).
  Warns but doesn't block creation.
  """

  import Ecto.Query, warn: false
  alias TheBridge.Repo
  alias TheBridge.Clients.Client

  def check_duplicates(initials, birth_year)
      when is_binary(initials) and is_integer(birth_year) do
    Client
    |> where([c], c.initials == ^initials)
    |> where([c], c.birth_year >= ^(birth_year - 1) and c.birth_year <= ^(birth_year + 1))
    |> where([c], c.status != "archived")
    |> select([c], %{
      id: c.id,
      bridge_id: c.bridge_id,
      alias_name: c.alias_name,
      initials: c.initials,
      birth_year: c.birth_year,
      agency_id: c.agency_id
    })
    |> Repo.all()
  end

  def check_duplicates(_initials, _birth_year), do: []

  def check_for_client(attrs) when is_map(attrs) do
    first = attrs[:first_name] || attrs["first_name"]
    last = attrs[:last_name] || attrs["last_name"]
    dob = attrs[:date_of_birth] || attrs["date_of_birth"]

    with <<f::binary-size(1), _::binary>> <- first,
         <<l::binary-size(1), _::binary>> <- last,
         year when is_integer(year) <- extract_year(dob) do
      initials = String.upcase(f <> l)
      check_duplicates(initials, year)
    else
      _ -> []
    end
  end

  defp extract_year(%Date{year: year}), do: year
  defp extract_year(year) when is_integer(year), do: year

  defp extract_year(str) when is_binary(str) do
    case Date.from_iso8601(str) do
      {:ok, date} -> date.year
      _ -> nil
    end
  end

  defp extract_year(_), do: nil
end
