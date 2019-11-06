# Auth Shield [![Build Status](https://travis-ci.com/lcpojr/auth_shield.svg?branch=master)](https://travis-ci.com/lcpojr/auth_shield) [![Coverage Status](https://coveralls.io/repos/github/lcpojr/auth_shield/badge.svg?branch=master)](https://coveralls.io/github/lcpojr/auth_shield?branch=master)

Elixir authentication and authorization

AuthShield is an simple implementation that was created to be used with other frameworks (as Phoenix) or applications in order to provide an simple authentication and authorization management to the services.

## How to use

To install the dependency set `{:auth_shield, "~> 0.0.1"}` on your mix deps.

You can configure AuthX to use you database by setting on your `config.exs`:

```elixir
config :auth_shield, AuthShield.Repo,
  database: "authx_ex_#{Mix.env()}",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432
```

The default session expiration is 15 minutes but you can change it setting on your `config.exs`:

```elixir
config :auth_shield, AuthShield,
  # 15 minutes (in seconds)
  session_expiration: 60 * 15
```

To create a new user use:

```elixir
AuthShield.signup(%{
    first_name: "Lucas",
    last_name: "Mesquita",
    email: "lucas@gmail.com",
    password: "My_passw@rd2"
})
```

To login an user use:

```elixir
AuthShield.login(
    %{"email" => "lucas@gmail.com", "password" => "Mypass@rd23"},
    remote_ip: "172.31.4.1",
    user_agent: "Mozilla/5.0 (Windows NT x.y; rv:10.0) Gecko/20100101 Firefox/10.0"
)
```

AuthShield has an authentication Plug (`AuthShield.Authentication.Plugs.AuthSession`) that can
be used to check if an user is authenticated or not in other endpoints.

If you are using phoenix and our Authentication Plug you should save the session in private on
your as the exemple bellow:

```elixir
conn
|> put_private(:session, session)
|> put_status(200)
```

## Documentation

You can check out the documentation [here](https://hexdocs.pm/auth_shield/AuthShield.html).

### Extras

To know more about how we store the data and the authentication / authorization flow check links bellow:

- [Authentication architecture](https://github.com/lcpojr/auth_shield/blob/master/docs/authentication.md);
- [Authorization architecture](https://github.com/lcpojr/auth_shield/blob/master/docs/authorization.md);
- [Database architecture](https://github.com/lcpojr/auth_shield/blob/master/docs/database.md);
