#!/usr/bin/env bash
set -e
mix deps.get --only prod
mix compile
mix assets.deploy
mix phx.digest
