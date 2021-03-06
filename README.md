# Auth Shield [![Build Status](https://travis-ci.com/lcpojr/auth_shield.svg?branch=master)](https://travis-ci.com/lcpojr/auth_shield) [![Coverage Status](https://coveralls.io/repos/github/lcpojr/auth_shield/badge.svg?branch=master)](https://coveralls.io/github/lcpojr/auth_shield?branch=master)

AuthShield is an simple implementation that was created to be used with other frameworks (as Phoenix) or applications in order to provide an simple authentication and authorization management to the services.

## Installation

In order to download it add `{:auth_shield, "~> 0.0.4"}` to your list of dependencies in mix.exs.

Then run `mix deps.get` to install AuthShield and its dependencies, including Ecto, Plug and Argon2.

After the packages are installed you must configure your database and generates an migration to add the AuthShield tables to it.

On your `config.exs` set the configuration bellow:

```elixir
# This is the default auth_shield database configuration
# but its highly recomendate that you configure it to be in
# the same database if you want to extend the identity to
# your on custom tables.
config :auth_shield, ecto_repos: [AuthShield.Repo]

config :auth_shield, AuthShield.Repo,
  database: "authshield_#{Mix.env()}",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  port: 5432

# You can set the session expiration and block attempts by changing this config.
# All timestamps are in seconds.
config :auth_shield, AuthShield,
  session_expiration: 60 * 15,
  max_login_attempts: 10,
  login_block_time: 60 * 15,
  brute_force_login_interval: 1,
  brute_force_login_attempts: 3
```

In your `test.exs` use the configuration bellow to run it in sandbox mode:

```elixir
config :auth_shield, AuthShield.Repo, pool: Ecto.Adapters.SQL.Sandbox
```

After you finish the configurations use `mix ecto.gen.migration create_auth_shield_tables` to generate the migration that will be use on database and tables criation.

Go to the generated migration and call the AuthShield `up` and `down` migration functions as the exemple bellow:

```elixir
defmodule AuthShield.Repo.Migrations.CreateAuthShieldTables do
  use Ecto.Migration

  def up do
    AuthShield.Migrations.up()
  end

  def down do
    AuthShield.Migrations.down()
  end
end
```

Create the database database (if its not created yet) by using `mix ecto.migrate` and
then run the migrations with `mix ecto.migrate`.

## Usage

We will only cover the basic usage here, so if you want to know more check our documentation on hex by clicking [here](https://hexdocs.pm/auth_shield/AuthShield.html) or on the session bellow.

### Creating an user

To create a new user use this:

```elixir
AuthShield.signup(%{
    first_name: "Lucas",
    last_name: "Mesquita",
    email: "lucas@gmail.com",
    password: "My_passw@rd2"
})
```

### Authenticating

Now to test if the user can authenticate do:

```elixir
AuthShield.login(%{"email" => "lucas@gmail.com", "password" => "Mypass@rd23"})
```

If you are using phoenix or any application that use `Plug.Conn` you can just pass it on login as:

```elixir
AuthShield.login(%Plug.Conn%{body_params: %{"email" => "lucas@gmail.com", "password" => "Mypass@rd23"})
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

If you are using phoenix we recomend you to check out our utilities doc [here](https://github.com/lcpojr/auth_shield/blob/master/docs/utilities.md).

## Documentation

You can check out the documentation [here](https://hexdocs.pm/auth_shield/AuthShield.html).

### Extras

To know more about how we store the data and the authentication / authorization flow check links bellow:

- [Authentication architecture](https://github.com/lcpojr/auth_shield/wiki/Authentication);
- [Authorization architecture](https://github.com/lcpojr/auth_shield/wiki/Authorization);
- [Database architecture](https://github.com/lcpojr/auth_shield/wiki/Database);
- [Utilities](https://github.com/lcpojr/auth_shield/wiki/Utilities);