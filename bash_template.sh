#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# -----------------------------------------------------------------------------
# Copyright (C) Business Learning Incorporated (businesslearninginc.com)
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License at
# <http://www.gnu.org/licenses/> for more details.
#
# -----------------------------------------------------------------------------
#
# A bash template (BaT)
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
# script library sources and declarations
#
EXEC_DIR="$(dirname "$(readlink -f "$0")")"
source "${EXEC_DIR}/bash-lib/general"
source "${EXEC_DIR}/bash-lib/args"

# [user-config] set any external program dependencies here
declare -a REQ_PROGRAMS=('jq')

# -----------------------------------------------------------------------------
# perform script configuration, arguments parsing, and validation
#
check_program_dependencies "${REQ_PROGRAMS[@]}"
display_banner
scan_for_args "$@"
check_for_args_completeness

# -----------------------------------------------------------------------------
# [user-config] any code from this point on is custom code, using
# the sevices and variables available through the template
#

# declare arguments
ARG_ALPHA="$(get_config_arg_value alpha)"
ARG_BRAVO="$(get_config_arg_value bravo)"
ARG_CHARLIE="$(get_config_arg_value charlie)"
ARG_DELTA="$(get_config_arg_value delta)"
readonly ARG_ALPHA
readonly ARG_BRAVO
readonly ARG_CHARLIE
readonly ARG_DELTA

printf "%s\n" "alpha is $ARG_ALPHA"
printf "%s\n" "bravo is $ARG_BRAVO"

if [ -n "${ARG_CHARLIE}" ]; then
  printf "%s\n" "charlie is $ARG_CHARLIE"
fi

printf "%s\n" "delta is $ARG_DELTA"