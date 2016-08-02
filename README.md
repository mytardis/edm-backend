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

## Configure the database connection
Set the `DATABASE_URL` environment variable to an [ecto url](https://hexdocs.pm/ecto/Ecto.Repo.html), such as `ecto://postgres:postgres@localhost/database_name`

## Configuring Google OAuth
Set the following environment variables, analogous to the settings above:
  * `GOOGLE_CLIENT_ID`
  * `GOOGLE_CLIENT_SECRET`
  * `GOOGLE_REDIRECT_URI`

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: http://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
