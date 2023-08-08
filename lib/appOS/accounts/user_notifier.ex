defmodule AppOS.Accounts.UserNotifier do
  import Swoosh.Email

  require Phoenix.Component

  alias AppOS.Mailer
  alias AppOSWeb.Layouts
  alias AppOSWeb.EmailHTML
  alias AppOS.EmailVariables

  @email_variables %EmailVariables{
    name: nil,
    action_url: nil,
    reciever_email: nil
  }

  # Delivers the email using the application mailer.
  # defp deliver(recipient, subject, text_body) do
  #   # Access This Struct To Get Default Sender name And Sender Email
  #   assigns = %EmailVariables{name: nil, action_url: nil, reciever_email: nil}

  #   email =
  #     new()
  #     |> to(recipient)
  #     |> from({@email_variables.sender_name, @email_variables.sender_email})
  #     |> subject(subject)
  #     |> text_body(text_body)

  #   with {:ok, _metadata} <- Mailer.deliver(email) do
  #     {:ok, email}
  #   end
  # end

  defp deliver(recipient, subject, text_body, html_body, opts \\ []) do
    from = {
      "#{@email_variables.sender_name} - #{@email_variables.app_name}",
      @email_variables.sender_email
    }

    reply_to_email = Keyword.get(opts, :reply_to_email, nil)

    email =
      new()
      |> to(recipient)
      |> from(from)
      |> subject(subject)
      |> maybe_add_reply_to(reply_to_email)
      |> text_body(text_body)
      |> html_body(html_body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  defp maybe_add_reply_to(email, nil) do
    # If No Reply to Ignore It And Return `Email` As Is
    email
  end

  defp maybe_add_reply_to(email, reply_to_email) do
    # If Reply to Add It To The `Email` Pipe
    email |> reply_to(reply_to_email)
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    assigns = %EmailVariables{
      name: user.name,
      reciever_email: user.email,
      action_url: url
    }

    deliver(
      user.email,
      "#{assigns.app_name} - Confirmation Instructions",
      text_body_with_layout(assigns, &EmailHTML.welcome_text/1),
      html_body_with_layout(assigns, &EmailHTML.welcome_html/1)
    )
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    assigns = %EmailVariables{
      name: user.name,
      reciever_email: user.email,
      action_url: url
    }

    deliver(
      user.email,
      "#{assigns.app_name} - Update Email Instructions",
      text_body_with_layout(assigns, &EmailHTML.email_change_text/1),
      html_body_with_layout(assigns, &EmailHTML.email_change_html/1)
    )
  end

  @doc """
  Deliver instructions to confirm account.
  member user -> new user that is being invited to the organization
  ownwer user -> organization admin user that is inviting the new user (member user)
  """
  def deliver_invite_instructions(member_user, owner_user, url) do
    assigns = %EmailVariables{
      name: member_user.name,
      reciever_email: member_user.email,
      action_url: url,
      invite_sender_email: owner_user.email
    }

    deliver(
      member_user.email,
      "#{assigns.app_name} - Team Invite Instructions",
      text_body_with_layout(assigns, &EmailHTML.team_invite_text/1),
      html_body_with_layout(assigns, &EmailHTML.team_invite_html/1),
      reply_to_email: owner_user.email
    )
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    assigns = %EmailVariables{
      name: user.name,
      reciever_email: user.email,
      action_url: url
    }

    deliver(
      user.email,
      "#{assigns.app_name} - Reset Password",
      text_body_with_layout(assigns, &EmailHTML.forgot_password_text/1),
      html_body_with_layout(assigns, &EmailHTML.forgot_password_html/1)
    )
  end

  def html_body_with_layout(%EmailVariables{} = assigns, inner_content) do
    # Same Assings in Both Layout And Inner Content Hence Passing A Module Function
    # And Then Calling it with the same assigns
    %{assigns: assigns, inner_content: inner_content.(%{assigns: assigns})}
    |> Layouts.email_html()
    |> to_binary()
  end

  def text_body_with_layout(%EmailVariables{} = assigns, inner_content) do
    %{assigns: assigns, inner_content: inner_content.(%{assigns: assigns})}
    |> Layouts.email_text()
    |> to_binary()
  end

  defp to_binary(rendered), do: rendered |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()
  # defp to_html(mjml_binary), do: with({:ok, html} <- Mjml.to_html(mjml_binary), do: html)
end
