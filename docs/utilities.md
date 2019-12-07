# Utilities

If you are using phoenix `AuthShield` you can use our plug and validations in order to
provide authentication to your endpoints.

## Forms

If you are using Phonenix HTML forms you can just use our login and signup schema to build it.
On your controller use:

```elixir
    render(conn, "login.html", form_changeset: AuthShield.Validations.Login())
```

After that you can just pass it throw your templates:

```elixir
    <%= form_for @form_changeset, Routes.page_path(@conn, :login), fn f -> %>
        <div class="form-group">
            <%= label f, :email, class: "control-label" %>
            <%= email_input f, :email %>
            <%= error_tag f, :email %>
        </div>
        <div class="form-group">
            <%= label f, :password, class: "control-label" %>
            <%= password_input f, :password %>
            <%= error_tag f, :password %>
        </div>

        <%= submit "Submit" %>
    <% end %>
```

You can do just the same for `AuthShield.Validations.SignUp`.

## Plugs

If you has an endpoint that you need to be authenticate and don't wan't
to handle with it by calling all authentication functions you can use
the session plug to get do it and just declare a fallback:

In your router add it:

```elixir
    pipeline :authenticated do
        plug(AuthShield.Authentication.Plugs.AuthSession)
    end

    scope "/profile/change-password" do
        pipe_through(:authenticated)
        get("/", ProfilesController, :change_password)
        post("/", ProfilesController, :change_password)
    end
```

If someone tries to access these endpoints without has an active session the plug
will return `{:error, :unauthenticated}`.