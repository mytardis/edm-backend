#!/bin/bash
export MIX_ENV=test
export DATABASE_URL=ecto://postgres:postgres@localhost/edm_backend_test
mix test
