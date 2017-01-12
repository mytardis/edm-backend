#!/bin/bash
export MIX_ENV=dev
export DATABASE_URL=ecto://root@localhost/edm_backend_dev
export EDM_OAUTH_CLIENT_ID=oidcCLIENT
export EDM_OAUTH_CLIENT_SECRET=91c0fabd17a9db3cfe53f28a10728e39b7724e234ecd78dba1fb05b909fb4ed98c476afc50a634d52808ad3cb2ea744bc8c3b45b7149ec459b5c416a6e8db242
export EDM_OAUTH_DISCOVERY_URL=http://localhost:5000/.well-known/openid-configuration
mix deps.get
mix ecto.create
mix ecto.migrate
mix phoenix.server
