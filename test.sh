#!/bin/bash
export MIX_ENV=test
mix test 1>&1
if [ -v COVERALLS_REPO_TOKEN ]; then
   mix coveralls.semaphore 1>&1
fi
