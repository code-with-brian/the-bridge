defmodule TheBridge.Accounts.UserNotifier do
  import Swoosh.Email

  alias TheBridge.Mailer
  alias TheBridge.Accounts.User

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"TheBridge", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to log in with a magic link.
  """
  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    deliver(user.email, "Log in instructions", """

    ==============================

    Hi #{user.email},

    You can log into your account by visiting the URL below:

    #{url}

    If you didn't request this email, please ignore this.

    ==============================
    """)
  end

  defp deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  def deliver_donation_receipt(user, donation) do
    deliver(user.email, "Thank you for your donation!", """

    ==============================

    Hi #{user.display_name || user.email},

    Thank you for your generous donation of $#{format_cents(donation.amount_cents)} through The Bridge.

    Your support makes a real difference in someone's life.

    ==============================
    """)
  end

  def deliver_weekly_digest(user, updates) do
    update_text =
      updates
      |> Enum.take(5)
      |> Enum.map_join("\n", fn u -> "- #{u.body}" end)

    deliver(user.email, "Your weekly update from The Bridge", """

    ==============================

    Hi #{user.display_name || user.email},

    Here are updates on the needs you've supported:

    #{update_text}

    Visit The Bridge to see more details.

    ==============================
    """)
  end

  defp format_cents(cents), do: :erlang.float_to_binary(cents / 100, decimals: 2)
end
