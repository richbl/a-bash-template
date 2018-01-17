#!/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# -----------------------------------------------------------------------------
# Copyright (C) Business Learning Incorporated (businesslearninginc.com)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.
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
#   may be needed to customize this bash template
#

# -----------------------------------------------------------------------------
# script declarations
#
shopt -s extglob
EXEC_DIR="$(dirname "$0")"
# shellcheck source=bash-lib/args
source "${EXEC_DIR}/bash-lib/args"
# shellcheck source=bash-lib/general
source "${EXEC_DIR}/bash-lib/general"

ARGS_FILE="${EXEC_DIR}/data/config.json"

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
printf "%s\n" "alpha is $(get_config_arg_value alpha)"
printf "%s\n" "bravo is $(get_config_arg_value bravo)"
printf "%s\n" "charlie is $(get_config_arg_value charlie)"
printf "%s\n" "delta is $(get_config_arg_value delta)"