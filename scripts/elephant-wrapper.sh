#!/usr/bin/env bash

# Elephant wrapper to set up Lua paths for lsqlite3
# This ensures Elephant can find the locally installed Lua rocks

# Set up Lua paths
eval $(luarocks path --lua-version 5.4)

# Launch Elephant with all arguments passed through
exec elephant "$@"
