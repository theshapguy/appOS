defmodule AppOS.EmailVariables do
  @enforce_keys [:action_url, :name, :reciever_email]

  defstruct [
      # Common (in every tempalte)
      :name,
      :reciever_email,
      :action_url,
      :invite_sender_email,


      # Default Values
      app_name: Application.compile_env(:appos, AppOS.Mailer)[:app_name],
      sender_name: Application.compile_env(:appos, AppOS.Mailer)[:sender_name],
      sender_email: Application.compile_env(:appos, AppOS.Mailer)[:sender_email],
      icon: Application.compile_env(:appos, AppOS.Mailer)[:icon],
  ]
end

    # EmailHTML.welcome_text(%{})

    # deliver(user.email, "Confirmation instructions", """

    # ==============================

    # Hi #{user.email},

    # You can confirm your account by visiting the URL below:

    # #{url}

    # If you didn't create an account with us, please ignore this.

    # ==============================
    # """,
    # html_body_with_layout(assigns, EmailHTML.welcome_html(assigns))
    # )


    # deliver(user.email, "#{assigns.app_name} - Update Email Instructions", """

    # ==============================

    # Hi #{user.email},

    # You can change your email by visiting the URL below:

    # #{url}

    # If you didn't request this change, please ignore this.

    # ==============================
    # """)
