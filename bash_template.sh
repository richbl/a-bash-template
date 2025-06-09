#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Copyright (c) 2025 Richard Bloch
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# -----------------------------------------------------------------------------
#
# A Bash Template (BaT) Project
# Demonstrating the use of the bash-lib project for argument parsing and configuration
# Version 1.2.0
#
# requirements:
#  --jq program installed: used to parse /data/config.json
#
# inputs:
#  --[user-config] configured through /data/config.json
#
# outputs:
#  --notification of script success/failure
#  --side-effect(s): [user-config]
#

#
# NOTE:
#   The string '[user-config]' is an indication that some user configuration
#   may be needed to customize this script
#

# -----------------------------------------------------------------------------
# Script library sources and declarations
#
EXEC_DIR="$(dirname "$(readlink -f "$0")")"
source "${EXEC_DIR}/bash-lib/general"
source "${EXEC_DIR}/bash-lib/args"

# [user-config] set any external program dependencies here
declare -a REQ_PROGRAMS=('jq')

# -----------------------------------------------------------------------------
# Perform script configuration, arguments parsing, and validation
#
check_program_dependencies "${REQ_PROGRAMS[@]}"
display_banner
scan_for_args "$@"
check_for_args_completeness

# -----------------------------------------------------------------------------
# [user-config] any code from this point on is custom code, using
# the services and variables available through the bash-lib library
#

# Declare and define arguments
ARG_ALPHA="$(get_config_arg_value alpha)"
ARG_BRAVO="$(get_config_arg_value bravo)"
ARG_CHARLIE="$(get_config_arg_value charlie)"
ARG_DELTA="$(get_config_arg_value delta)"

# Make arguments read-only (optional, but recommended for larger scripts)
readonly ARG_ALPHA
readonly ARG_BRAVO
readonly ARG_CHARLIE
readonly ARG_DELTA

# Display arguments
printf "%s\n" "alpha is $ARG_ALPHA"
printf "%s\n" "bravo is $ARG_BRAVO"

if [ -n "${ARG_CHARLIE}" ]; then
  printf "%s\n" "charlie is $ARG_CHARLIE"
fi

printf "%s\n" "delta is $ARG_DELTA"
