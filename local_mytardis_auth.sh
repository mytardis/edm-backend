#!/bin/bash
export MIX_ENV=dev
if [ -z ${DATABASE_URL+x} ]; 
then
  export DATABASE_URL=ecto://root@localhost/edm_backend_dev
fi
export EDM_OAUTH_CLIENT_ID=532011
export EDM_OAUTH_CLIENT_SECRET=91d60f25c7407866a76fd6ee4ccdd2ab53614349d4d7da8136700079
export EDM_OAUTH_DISCOVERY_URL=http://server:8000/.well-known/openid-configuration
mix deps.get
mix ecto.create
mix ecto.migrate
mix phoenix.server
