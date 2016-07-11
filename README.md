# EDM Backend

[![Build Status](https://semaphoreci.com/api/v1/mytardis/edm-backend/branches/master/badge.svg)](https://semaphoreci.com/mytardis/edm-backend)
[![Coverage Status](https://coveralls.io/repos/github/mytardis/edm-backend/badge.svg?branch=master)](https://coveralls.io/github/mytardis/edm-backend?branch=master)

To start your Phoenix app:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Install Node.js dependencies with `npm install`
  * Start Phoenix endpoint with `mix phoenix.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Configuring Google OAuth
1. Add a secrets file if it's not there already, e.g. `/config/dev.secret.exs` or `/config/prod.secret.exs`
2. Add the client id and secret:

```
use Mix.Config

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: "...",
  client_secret: "...",
  redirect_uri: "http://localhost:4000/oauth/google/callback"
```

Replace the `redirect_uri` as appropriate.

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
