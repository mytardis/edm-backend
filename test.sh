#!/bin/bash
export MIX_ENV=test
export EDM_OAUTH_CLIENT_ID=oidcCLIENT
export EDM_OAUTH_CLIENT_SECRET=91c0fabd17a9db3cfe53f28a10728e39b7724e234ecd78dba1fb05b909fb4ed98c476afc50a634d52808ad3cb2ea744bc8c3b45b7149ec459b5c416a6e8db242
export EDM_OAUTH_DISCOVERY_URL=http://localhost:5000/.well-known/openid-configuration
mix test 1>&1
if [ -v COVERALLS_REPO_TOKEN ]; then
   mix coveralls.semaphore 1>&1
fi
