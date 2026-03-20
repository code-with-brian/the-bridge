# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs

alias TheBridge.{Repo, Agencies, Accounts, Clients, Vendors}
alias TheBridge.Agencies.Agency
alias TheBridge.Accounts.User
alias TheBridge.Clients.{Client, Need}
alias TheBridge.Vendors.Vendor

# Agencies — Peterborough social services
agencies_data = [
  %{
    name: "Brock Mission",
    slug: "brock-mission",
    description: "Emergency shelter and support services for men experiencing homelessness.",
    city: "Peterborough",
    province: "ON",
    verified: true
  },
  %{
    name: "YES Shelter for Youth and Families",
    slug: "yes-shelter",
    description: "Emergency shelter for youth and families in crisis.",
    city: "Peterborough",
    province: "ON",
    verified: true
  },
  %{
    name: "One City Peterborough",
    slug: "one-city",
    description: "Coordinated approach to ending homelessness.",
    city: "Peterborough",
    province: "ON",
    verified: true
  },
  %{
    name: "Trinity United Church",
    slug: "trinity-united",
    description: "Community meals and support programs.",
    city: "Peterborough",
    province: "ON",
    verified: true
  },
  %{
    name: "CCRC Peterborough",
    slug: "ccrc",
    description: "Community Counselling and Resource Centre.",
    city: "Peterborough",
    province: "ON",
    verified: true
  },
  %{
    name: "CMHA Haliburton Kawartha Pine Ridge",
    slug: "cmha-hkpr",
    description: "Mental health and addictions services.",
    city: "Peterborough",
    province: "ON",
    verified: true
  },
  %{
    name: "Fourcast",
    slug: "fourcast",
    description: "Addiction and mental health services.",
    city: "Peterborough",
    province: "ON",
    verified: true
  },
  %{
    name: "PARN",
    slug: "parn",
    description: "Peterborough AIDS Resource Network — harm reduction and support.",
    city: "Peterborough",
    province: "ON",
    verified: true
  },
  %{
    name: "YWCA Crossroads Shelter",
    slug: "ywca-crossroads",
    description: "Emergency shelter for women and children fleeing violence.",
    city: "Peterborough",
    province: "ON",
    verified: true
  },
  %{
    name: "Street Level Advocacy",
    slug: "street-level",
    description: "Peer-led advocacy and outreach for people experiencing homelessness.",
    city: "Peterborough",
    province: "ON",
    verified: true
  }
]

agencies =
  for data <- agencies_data do
    {:ok, agency} =
      case Repo.get_by(Agency, slug: data.slug) do
        nil -> Agencies.create_agency(data)
        existing -> {:ok, existing}
      end

    agency
  end

brock = Enum.find(agencies, &(&1.slug == "brock-mission"))
yes = Enum.find(agencies, &(&1.slug == "yes-shelter"))

# Demo users
create_user = fn email, display_name, role, agency ->
  case Accounts.get_user_by_email(email) do
    nil ->
      {:ok, user} =
        %User{}
        |> User.registration_changeset(%{
          email: email,
          display_name: display_name,
          password: "password123456"
        })
        |> User.role_changeset(%{role: role, agency_id: agency && agency.id})
        |> Ecto.Changeset.put_change(:confirmed_at, DateTime.utc_now(:second))
        |> Repo.insert()

      user

    user ->
      user
  end
end

_admin = create_user.("admin@thebridge.ca", "Platform Admin", "platform_admin", nil)
_agency_admin = create_user.("sarah@brockmission.ca", "Sarah Johnson", "agency_admin", brock)
worker = create_user.("mike@brockmission.ca", "Mike Chen", "agency_worker", brock)
yes_worker = create_user.("lisa@yesshelter.ca", "Lisa Park", "agency_worker", yes)
_donor = create_user.("donor@example.com", "Alex Donor", "donor", nil)

# Demo clients
clients_data = [
  %{
    first_name: "James",
    last_name: "Wilson",
    alias_name: "Jay",
    story:
      "Jay has been working with Brock Mission after losing his apartment. He's motivated to get back on his feet and is looking for help with employment essentials.",
    gender: "male",
    date_of_birth: ~D[1985-03-15],
    housing_status: "emergency_shelter",
    consent_signed: true,
    agency_id: brock.id,
    primary_worker_id: worker.id
  },
  %{
    first_name: "Maria",
    last_name: "Santos",
    alias_name: "Maria S.",
    story:
      "Maria recently arrived in Peterborough with her two children. She's staying at YES Shelter while working with a case worker to find permanent housing.",
    gender: "female",
    date_of_birth: ~D[1992-07-22],
    housing_status: "emergency_shelter",
    consent_signed: true,
    agency_id: yes.id,
    primary_worker_id: yes_worker.id
  },
  %{
    first_name: "Robert",
    last_name: "Anderson",
    alias_name: "Rob A.",
    story:
      "Rob has been unhoused for over a year. He's a veteran dealing with PTSD and is working with CMHA for mental health support.",
    gender: "male",
    date_of_birth: ~D[1978-11-03],
    housing_status: "unsheltered",
    consent_signed: true,
    agency_id: brock.id,
    primary_worker_id: worker.id
  }
]

clients =
  for data <- clients_data do
    case Repo.get_by(Client, alias_name: data.alias_name) do
      nil ->
        case Clients.create_client(data) do
          {:ok, client} -> client
          {:ok, client, _duplicates} -> client
        end

      existing ->
        existing
    end
  end

# Demo needs
needs_data = [
  %{
    title: "Winter boots (size 10)",
    description: "Jay needs warm winter boots for his job search. Size 10 men's.",
    category: "clothing",
    priority: "urgent",
    amount_cents: 8500,
    client_id: Enum.at(clients, 0).id,
    created_by_id: worker.id
  },
  %{
    title: "Bus pass (monthly)",
    description: "Monthly transit pass so Jay can get to job interviews and appointments.",
    category: "transit",
    priority: "high",
    amount_cents: 9000,
    client_id: Enum.at(clients, 0).id,
    created_by_id: worker.id
  },
  %{
    title: "School supplies for two children",
    description: "Backpacks, notebooks, and supplies for Maria's kids starting at a new school.",
    category: "education",
    priority: "high",
    amount_cents: 15000,
    client_id: Enum.at(clients, 1).id,
    created_by_id: yes_worker.id
  },
  %{
    title: "Hygiene kit",
    description: "Basic hygiene supplies: soap, shampoo, toothbrush, toothpaste, deodorant.",
    category: "hygiene",
    priority: "normal",
    amount_cents: 3500,
    client_id: Enum.at(clients, 2).id,
    created_by_id: worker.id
  },
  %{
    title: "ID replacement documents",
    description: "Help covering fees for replacing lost Ontario ID and health card.",
    category: "documents",
    priority: "high",
    amount_cents: 7500,
    client_id: Enum.at(clients, 2).id,
    created_by_id: worker.id
  },
  %{
    title: "Warm meals — one week",
    description:
      "Hot meal vouchers for a week while Rob connects with more permanent food support.",
    category: "food",
    priority: "urgent",
    amount_cents: 5000,
    funded_cents: 2000,
    status: "partially_funded",
    client_id: Enum.at(clients, 2).id,
    created_by_id: worker.id
  }
]

for data <- needs_data do
  case Repo.get_by(Need, title: data.title) do
    nil -> Clients.create_need(data)
    _ -> :ok
  end
end

# Demo vendors
vendors_data = [
  %{
    name: "Mark's Work Wearhouse",
    slug: "marks",
    category: "clothing",
    city: "Peterborough",
    discount_percentage: Decimal.new("10")
  },
  %{name: "Shoppers Drug Mart", slug: "shoppers", category: "hygiene", city: "Peterborough"},
  %{
    name: "Peterborough Transit",
    slug: "ptbo-transit",
    category: "transit",
    city: "Peterborough",
    discount_percentage: Decimal.new("15")
  },
  %{name: "Staples", slug: "staples", category: "education", city: "Peterborough"}
]

for data <- vendors_data do
  case Repo.get_by(Vendor, slug: data.slug) do
    nil -> Vendors.create_vendor(data)
    _ -> :ok
  end
end

IO.puts("Seeds complete!")
IO.puts("  #{length(agencies)} agencies")
IO.puts("  5 demo users (admin@thebridge.ca / password123456)")
IO.puts("  #{length(clients)} clients")
IO.puts("  #{length(needs_data)} needs")
IO.puts("  #{length(vendors_data)} vendors")
