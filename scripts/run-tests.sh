#!/usr/bin/env bash

# Run busted tests with the correct Lua path
LUA_PATH="./lua/?.lua;./lua/?/init.lua;./?/init.lua;./?.lua;$LUA_PATH" busted "$@"