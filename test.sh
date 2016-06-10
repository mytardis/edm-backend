#!/bin/bash
export MIX_ENV=test
mix test 1>&1
if [ -z ${COVERALLS_REPO_TOKEN+x} ]; then
   mix coveralls.semaphore 1>&1
fi
