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
# Bash Test Runner for BASH-LIB libraries
# Tests the functionality of the 'args' and 'general' bash-lib libraries
# Version 1.2.0

# --- Configuration -----------------------------------------------------------
#
TEST_TMP_DIR=""
ARGS_LIBS_FILE="bash-lib/args"
GENERAL_LIBS_FILE="bash-lib/general"
DUMMY_CONFIG_CONTENT='
{
  "details":
    {
      "title": "A bash template (BaT) to ease argument parsing and management",
      "syntax": "bash_template.sh -a alpha -b bravo [-c charlie] -d delta",
      "version": "1.2.0"
    },
  "arguments":
    [
      {
        "short_form": "-a",
        "long_form": "--alpha",
        "text_string": "alpha",
        "description": "alpha (something descriptive)",
        "required": true
      },
      {
        "short_form": "-b",
        "long_form": "--bravo",
        "text_string": "bravo",
        "description": "bravo (something descriptive)",
        "required": true
      },
      {
        "short_form": "-c",
        "long_form": "--charlie",
        "text_string": "charlie",
        "description": "charlie (this is optional)",
        "required": false
      },
      {
        "short_form": "-d",
        "long_form": "--delta",
        "text_string": "delta",
        "description": "delta (something descriptive)",
        "required": true
      }
    ]
}'

# --- Constants and variables -----------------------------------------------
#
TOTAL_TESTS=0
FAILED_TESTS=0

# Declare ARG_VALUE as an associative array
declare -A ARG_VALUE
declare -a REQ_PROGRAMS=('jq')

# -----------------------------------------------------------------------------
# log() echoes a formatted message to stderr
#
log() {
  echo "$(date '+%Y/%m/%d %H:%M:%S') $*" >&2
}

# -----------------------------------------------------------------------------
# test_suite_start() starts a test suite
#
test_suite_start() {

  log "+---- Starting Test Suite: $1"
  log "|"

}

# -----------------------------------------------------------------------------
# test_suite_end() ends a test suite
#
test_suite_end() {

  log "|"
  log "+---- Finished Test Suite: $1"
  log ""

}

# -----------------------------------------------------------------------------
# test_case_start() starts a test case
#
test_case_start() {

  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  log "| Running Test Case $TOTAL_TESTS: $1:"

}

# -----------------------------------------------------------------------------
# test_case_end() generates output at the end of a test case
#
test_case_end() {
  log "|"
}

# -----------------------------------------------------------------------------
# test_case_pass() marks a test case as successful
#
test_case_pass() {
  log "| ✅ PASS"
}

# -----------------------------------------------------------------------------
# test_case_fail() marks a test case as failed
#
test_case_fail() {

  FAILED_TESTS=$((FAILED_TESTS + 1))
  log "| ❌ FAIL"

  if [[ -n "$1" ]]; then
    log "     Reason: $1"
  fi

}

# -----------------------------------------------------------------------------
# assert_equal() checks if two values are equal
#
assert_equal() {

  local expected="$1"
  local actual="$2"
  local message="$3"

  if [[ "$actual" == "$expected" ]]; then
    test_case_pass
  else
    test_case_fail "Output mismatch. $message
                         Expected: $expected
                         Actual: $actual"
  fi

}

# -----------------------------------------------------------------------------
# assert_success() checks if a command exits with a success status
#
assert_success() {

  local command_str="$1"
  local message="$2"
  local output=""
  local status=0

  # Run command in a sub-shell to prevent it from affecting main script flow
  output=$(
    (eval "$command_str") 2>&1
  )
  status=$?

  if [[ $status -eq 0 ]]; then
    test_case_pass
  else
    test_case_fail "Command failure. $message
                         Expected: 0
                         Actual: $status"
  fi

}

# -----------------------------------------------------------------------------
# assert_failure() checks if a command exits with a failure status
#
assert_failure() {

  local expected_status="$1"
  local command_str="$2"
  local message="$3"
  local output=""
  local status=0

  # Run command in a sub-shell to prevent it from affecting main script flow
  output=$(
    (eval "$command_str") 2>&1
  )
  status=$?

  if [[ $status -eq "$expected_status" ]]; then
    test_case_pass
  else
    test_case_fail "Command failure. $message
                         Expected: $expected_status
                         Actual: $status"
  fi

}

# -----------------------------------------------------------------------------
# assert_output() checks if a command's output matches a given string
#
assert_output() {

  local expected_output="$1"
  local command_str="$2"
  local message="$3"
  local actual_output=""

  # Run command in a sub-shell and capture stdout/stderr
  actual_output=$(
    (eval "$command_str") 2>&1
  )

  expected_output="${expected_output//$'\r'/}"
  actual_output="${actual_output//$'\r'/}"

  if [[ "$actual_output" == "$expected_output" ]]; then
    test_case_pass
  else
    test_case_fail "Output mismatch. $message
                         Expected: $expected_output
                         Actual: $actual_output"
  fi

}

# -----------------------------------------------------------------------------
# assert_file_exists() checks if a file exists
#
assert_file_exists() {

  local file_path="$1"
  local message="$2"

  if [[ -f "$file_path" ]]; then
    test_case_pass
  else
    test_case_fail "File '$file_path' does not exist. $message"
  fi

}

# -----------------------------------------------------------------------------
# assert_dir_exists() checks if a directory exists
#
assert_dir_exists() {

  local dir_path="$1"
  local message="$2"

  if [[ -d "$dir_path" ]]; then
    test_case_pass
  else
    test_case_fail "Directory '$dir_path' does not exist. $message"
  fi

}

# -----------------------------------------------------------------------------
# assert_program_exists() checks if a program exists in the PATH
#
assert_program_exists() {

  local program_name="$1"
  local message="$2"

  if command -v "$program_name" &>/dev/null; then
    test_case_pass
  else
    test_case_fail "Program '$program_name' not found in PATH. $message"
  fi

}

# -----------------------------------------------------------------------------
# setup_suite() sets up the test environment
#
setup_suite() {

  log ""
  log "+---- Setting Up Test Environment"
  log "|"

  # Create a temporary directory for test files and config
  TEST_TMP_DIR=$(mktemp -d -t bash_test_XXXXXX)
  log "| ✅ Created temporary directory: $TEST_TMP_DIR"

  # Create the data directory required by ARGS
  mkdir -p "$TEST_TMP_DIR/data"
  log "| ✅ Created directory: $TEST_TMP_DIR/data"

  # Create the dummy config.json file
  echo "$DUMMY_CONFIG_CONTENT" >"$TEST_TMP_DIR/data/config.json"
  log "| ✅ Created dummy config file: $TEST_TMP_DIR/data/config.json"

  # Create a dummy bin directory for program dependency tests
  mkdir -p "$TEST_TMP_DIR/bin"
  log "| ✅ Created directory: $TEST_TMP_DIR/bin"
  log "|"

  # Create dummy executable programs
  touch "$TEST_TMP_DIR/bin/dummy_program_1"
  chmod +x "$TEST_TMP_DIR/bin/dummy_program_1"
  log "| ✅ Created dummy executable: $TEST_TMP_DIR/bin/dummy_program_1"

  touch "$TEST_TMP_DIR/bin/dummy_program_2"
  chmod +x "$TEST_TMP_DIR/bin/dummy_program_2"
  log "| ✅ Created dummy executable: $TEST_TMP_DIR/bin/dummy_program_2"

  # Create dummy files for file dependency tests
  touch "$TEST_TMP_DIR/dummy_file_1.txt"
  log "| ✅ Created dummy file: $TEST_TMP_DIR/dummy_file_1.txt"

  touch "$TEST_TMP_DIR/dummy_file_2.txt"
  log "| ✅ Created dummy file: $TEST_TMP_DIR/dummy_file_2.txt"

  # Create dummy directories for directory existence tests
  mkdir "$TEST_TMP_DIR/dummy_dir_1"
  log "| ✅ Created dummy directory: $TEST_TMP_DIR/dummy_dir_1"
  mkdir "$TEST_TMP_DIR/dummy_dir_2"
  log "| ✅ Created dummy directory: $TEST_TMP_DIR/dummy_dir_2"
  log "|"

  # Source the scripts used for testing
  #
  # ARGS uses EXEC_DIR and ARGS_LIBS_FILE, so we need to set EXEC_DIR before sourcing ARGS so it finds
  # the dummy config.json
  #
  # GENERAL defines quit(), which is used by ARGS, so source GENERAL first
  #
  log "| ✅ Sourcing scripts under test"
  export EXEC_DIR="$TEST_TMP_DIR"
  log "| ✅ Set EXEC_DIR=$EXEC_DIR"

  # Verify scripts exist before sourcing
  if [[ ! -f "$GENERAL_LIBS_FILE" ]]; then
    log "| ❌ Error: General script '$GENERAL_LIBS_FILE' not found!"
    exit 1
  fi
  if [[ ! -f "$ARGS_LIBS_FILE" ]]; then
    log "| ❌ Error: Args script '$ARGS_LIBS_FILE' not found!"
    exit 1
  fi

  # Source GENERAL first because ARGS uses the 'quit' function
  #
  # shellcheck source=../bash-lib/general
  source "$GENERAL_LIBS_FILE"

  # shellcheck source=../bash-lib/args
  source "$ARGS_LIBS_FILE"
  log "| ✅ Scripts sourced"

  # Check for program dependencies
  log "| ✅ Checking for program dependencies"

  # Capture stderr and exit status from check_program_dependencies
  local dep_check_output
  local dep_check_status
  dep_check_output=$(check_program_dependencies "${REQ_PROGRAMS[@]}" 2>&1)
  dep_check_status=$?

  # An error occurred. Prepend to the message it and exit
  if [[ $dep_check_status -ne 0 ]]; then
    log "| ❌ $dep_check_output" >&2
    exit "$dep_check_status"
  fi

  # Reset ARG_VALUE before running tests
  ARG_VALUE=()

  log "|"
  log "+---- Setup Complete"
  log ""
}

# -----------------------------------------------------------------------------
# teardown_suite() is run on exit to clean up the test environment
#
teardown_suite() {

  log ""
  log "+---- Cleaning Up Test Environment"
  log "|"

  if [[ -d "$TEST_TMP_DIR" ]]; then
    rm -rf "$TEST_TMP_DIR"
    log "| ✅ Removed temporary directory: $TEST_TMP_DIR"
  else
    log "| ✅ Temporary directory $TEST_TMP_DIR already removed or not created"
  fi

  log "| ✅ Teardown complete"

}

# Set trap to ensure teardown runs on exit
trap teardown_suite EXIT

# -----------------------------------------------------------------------------
# test_ARGS_jq_functions() tests the jq functions
#
test_ARGS_jq_functions() {

  test_suite_start "ARGS jq Functions"

  # Test get_config_details
  test_case_start "get_config_details (title)"
  assert_output "A bash template (BaT) to ease argument parsing and management" "get_config_details title" "Check title details"
  test_case_end

  test_case_start "get_config_details (version)"
  assert_output "1.2.0" "get_config_details version" "Check version details"
  test_case_end

  test_case_start "get_config_details (syntax)"
  assert_output "bash_template.sh -a alpha -b bravo [-c charlie] -d delta" "get_config_details syntax" "Check syntax details"
  test_case_end

  # Test get_config_arg
  test_case_start "get_config_arg (index 0, short_form)"
  assert_output "-a" "get_config_arg 0 short_form" "Check first arg short form"
  test_case_end

  test_case_start "get_config_arg (index 0, long_form)"
  assert_output "--alpha" "get_config_arg 0 long_form" "Check first arg long form"
  test_case_end

  test_case_start "get_config_arg (index 1, text string)"
  assert_output "bravo" "get_config_arg 1 text_string" "Check second arg text string"
  test_case_end

  test_case_start "get_config_arg (index 1, description)"
  assert_output "bravo (something descriptive)" "get_config_arg 1 description" "Check second arg description"
  test_case_end

  test_case_start "get_config_arg (index 2, required)"
  assert_output "false" "get_config_arg 2 required" "Check third arg required status"
  test_case_end

  # Test get_config_args_length
  test_case_start "get_config_args_length"
  assert_output "4" "get_config_args_length" "Check total number of arguments"

  test_suite_end "ARGS jq Functions"

}

# -----------------------------------------------------------------------------
# test_ARGS_scan_for_args() tests the scan_for_args function
#
test_ARGS_scan_for_args() {

  test_suite_start "ARGS scan_for_args"

  # Test case 1: Scan with long and short forms, some missing
  test_case_start "scan_for_args - long and short forms, some missing"
  ARG_VALUE=() # Reset global array

  scan_for_args "--alpha" "alpha_value" "-c" "charlie_value"

  assert_equal "alpha_value" "${ARG_VALUE[alpha]:-}" "Alpha arg value should be set"
  assert_equal "" "${ARG_VALUE[bravo]:-}" "bravo arg value should be empty (missing)"
  assert_equal "charlie_value" "${ARG_VALUE[charlie]:-}" "Charlie arg value should be set"
  test_case_end

  # Test case 2: Scan with different order
  test_case_start "scan_for_args - different order"
  ARG_VALUE=() # Reset global array
  scan_for_args "-c" "charlie_value_2" "--bravo" "bravo_value_2" "--alpha" "alpha_value_2"
  assert_equal "alpha_value_2" "${ARG_VALUE[alpha]:-}" "Alpha arg value should be set"
  assert_equal "bravo_value_2" "${ARG_VALUE[bravo]:-}" "bravo arg value should be set"
  assert_equal "charlie_value_2" "${ARG_VALUE[charlie]:-}" "Charlie arg value should be set"
  test_case_end

  # Test case 3: Scan with unknown arguments (should be ignored)
  test_case_start "scan_for_args - with unknown arguments"
  ARG_VALUE=() # Reset global array
  scan_for_args "--alpha" "alpha_value_3" "--unknown" "unknown_value" "-x" "x_value" "-b" "bravo_value_3"
  assert_equal "alpha_value_3" "${ARG_VALUE[alpha]:-}" "Alpha arg value should be set"
  assert_equal "bravo_value_3" "${ARG_VALUE[bravo]:-}" "bravo arg value should be set"
  assert_equal "" "${ARG_VALUE[charlie]:-}" "Charlie arg value should be empty (missing)"
  test_case_end

  # Test case 4: Scan with no arguments
  test_case_start "scan_for_args - with no arguments"
  ARG_VALUE=() # Reset global array
  scan_for_args
  assert_equal "" "${ARG_VALUE[alpha]:-}" "Alpha arg value should be empty"
  assert_equal "" "${ARG_VALUE[bravo]:-}" "bravo arg value should be empty"
  assert_equal "" "${ARG_VALUE[charlie]:-}" "Charlie arg value should be empty"

  test_suite_end "ARGS scan_for_args"

}

# -----------------------------------------------------------------------------
# test_ARGS_get_config_arg_value() tests the get_config_arg_value function
#
test_ARGS_get_config_arg_value() {

  test_suite_start "ARGS get_config_arg_value"

  # Test case 1: Find an existing value after scan
  test_case_start "get_config_arg_value - find existing value after scan"
  ARG_VALUE=() # Reset global array
  scan_for_args "--alpha" "" "--bravo" "bravo_value_to_find" "-c" "charlie_value_to_find"

  # The function prints to stdout, so we capture
  assert_output "bravo_value_to_find" "get_config_arg_value $(get_config_arg 1 text_string)" "Should find bravo value"

  # Test case 2: Find another existing value
  test_case_start "get_config_arg_value - find another existing value"
  # ARG_VALUE still contains values from previous test
  assert_output "charlie_value_to_find" "get_config_arg_value $(get_config_arg 2 text_string)" "Should find charlie value"

  # Test case 3: Try to find a value for a missing argument
  test_case_start "get_config_arg_value - find value for missing argument"

  # Alpha argument is missing in ARG_VALUE (above)
  assert_output "" "get_config_arg_value $(get_config_arg 0 text_string)" "Should output nothing for missing value"

  # Test case 4: Try to find value for an unknown text_string
  test_case_start "get_config_arg_value - find value for unknown text_string"
  assert_output "" "get_config_arg_value unknown_value" "Should output nothing for unknown text_string"

  test_suite_end "ARGS get_config_arg_value"

}

# -----------------------------------------------------------------------------
# test_ARGS_check_for_args_completeness() tests the check_for_args_completeness function
#
test_ARGS_check_for_args_completeness() {

  test_suite_start "ARGS check_for_args_completeness"

  # Test case 1: All required arguments present
  test_case_start "check_for_args_completeness - all required present"
  ARG_VALUE=() # Reset global array
  scan_for_args "--alpha" "a_value" "--bravo" "b_value" "--charlie" "c_value" "--delta" "d_value"

  # This should not call quit, so exit status should be 0 from the sub-shell
  assert_success "check_for_args_completeness" "Should succeed when all required args are present"
  test_case_end

  # Test case 2: One required argument missing
  test_case_start "check_for_args_completeness - one required missing (--alpha)"
  ARG_VALUE=()
  scan_for_args "-a" "" "--bravo" "b_value" "--charlie" "c_value" "--delta" "d_value" # Alpha missing

  # This should call quit 1 and print an error
  expected_output=$'Error: argument \'alpha\' (-a|--alpha) is missing.'
  assert_output "$expected_output" "check_for_args_completeness" "Should output error message for missing alpha"
  assert_failure 1 "check_for_args_completeness" "Should exit with status 1 for missing required arg"
  test_case_end

  # Test case 3: Another required argument missing
  test_case_start "check_for_args_completeness - one required missing (--bravo)"
  ARG_VALUE=()
  scan_for_args "--alpha" "a_value" "--charlie" "c_value" "--delta" "d_value" # Bravo missing

  expected_output=$'Error: argument \'bravo\' (-b|--bravo) is missing.'
  assert_output "$expected_output" "check_for_args_completeness" "Should output error message for missing bravo"
  assert_failure 1 "check_for_args_completeness" "Should exit with status 1 for missing required arg"
  test_case_end

  # Test case 4: Multiple required arguments missing
  test_case_start "check_for_args_completeness - multiple required missing (--alpha, --delta)"
  ARG_VALUE=()
  scan_for_args "--bravo" "b_value" # Alpha and delta missing

  # Output multiple errors, order depends on loop, check for both
  local output status
  output=$(
    (check_for_args_completeness) 2>&1
  ) || status=$?
  status=${status:-$?}

  # Check status
  if [[ $status -eq 1 ]]; then
    test_case_pass
  else
    test_case_fail "Expected status 1; Actual $status for multiple missing args."
  fi

  # Check output content (order might vary, check for presence of lines)
  local line1="Error: argument 'alpha' (-a|--alpha) is missing."
  local line2="Error: argument 'delta' (-d|--delta) is missing."

  local expected_output="$line1"$'\n'"$line2"

  if ! [[ "$output" == *"$line1"* && "$output" == *"$line2"* ]]; then
    test_case_fail "Output mismatch. $message
                         Expected: $expected_output
                         Actual: $output"
  fi

  test_suite_end "ARGS check_for_args_completeness"

}

# -----------------------------------------------------------------------------
# test_GENERAL_quit() tests the quit function
#
test_GENERAL_quit() {

  test_suite_start "GENERAL quit function"

  # Test case 1: quit 0
  test_case_start "quit 0"
  # Run quit in a sub-shell and check its exit status and output
  assert_output $'' "( quit 0 )" "quit 0 should print newline"
  assert_success "( quit 0 )" "quit 0 should exit with status 0"
  test_case_end

  # Test case 2: quit 1
  test_case_start "quit 1"
  assert_output $'' "( quit 1 )" "quit 1 should print newline"
  assert_failure 1 "( quit 1 )" "quit 1 should exit with status 1"
  test_case_end

  # Test case 3: quit with non-zero status
  test_case_start "quit 42"
  assert_output $'' "( quit 42 )" "quit 42 should print newline"
  assert_failure 42 "( quit 42 )" "quit 42 should exit with status 42"

  test_suite_end "GENERAL quit function"

}

# -----------------------------------------------------------------------------
# test_GENERAL_check_program_dependencies() tests the check_program_dependencies function
#
test_GENERAL_check_program_dependencies() {

  test_suite_start "GENERAL check_program_dependencies"

  # Temporarily add the dummy bin directory to PATH
  local old_path="$PATH"
  export PATH="$TEST_TMP_DIR/bin:$PATH"
  log "| Temporarily updated PATH for dependency checks: $PATH"

  # Test case 1: All dependencies exist (dummy programs)
  test_case_start "check_program_dependencies - all exist"
  assert_success "check_program_dependencies dummy_program_1 dummy_program_2 jq" "Should succeed when all programs exist"
  test_case_end

  # Test case 2: One dependency missing
  test_case_start "check_program_dependencies - one missing"
  local missing_program="non_existent_program"
  local expected_output=$"Error: program '$missing_program' not installed."
  assert_output "$expected_output" "check_program_dependencies dummy_program_1 $missing_program dummy_program_2" "Should output error for missing program"
  assert_failure 1 "check_program_dependencies dummy_program_1 $missing_program dummy_program_2" "Should exit with status 1 for missing program"
  test_case_end

  # Test case 3: No dependencies specified
  test_case_start "check_program_dependencies - no dependencies"
  assert_success "check_program_dependencies" "Should succeed when no dependencies are specified"
  test_case_end

  # Restore original PATH
  export PATH="$old_path"
  log "| Restored original PATH"

  test_suite_end "GENERAL check_program_dependencies"

}

# -----------------------------------------------------------------------------
# test_GENERAL_check_file_dependencies() tests the check_file_dependencies function
#
test_GENERAL_check_file_dependencies() {

  test_suite_start "GENERAL check_file_dependencies"

  # Paths relative to TEST_TMP_DIR
  local file1="$TEST_TMP_DIR/dummy_file_1.txt"
  local file2="$TEST_TMP_DIR/dummy_file_2.txt"
  local non_existent_file="$TEST_TMP_DIR/non_existent_file.txt"

  # Test case 1: All dependencies exist
  test_case_start "check_file_dependencies - all exist"
  assert_success "check_file_dependencies $file1 $file2" "Should succeed when all files exist"
  test_case_end

  # Test case 2: One dependency missing
  test_case_start "check_file_dependencies - one missing"
  local expected_output=$"Error: file '$non_existent_file' not found."
  assert_output "$expected_output" "check_file_dependencies $file1 $non_existent_file $file2" "Should output error for missing file"
  assert_failure 1 "check_file_dependencies $file1 $non_existent_file $file2" "Should exit with status 1 for missing file"
  test_case_end

  # Test case 3: No dependencies specified
  test_case_start "check_file_dependencies - no dependencies"
  assert_success "check_file_dependencies" "Should succeed when no dependencies are specified"

  test_suite_end "GENERAL check_file_dependencies"

}

# -----------------------------------------------------------------------------
# test_GENERAL_exist_directory() tests the exist_directory function
#
test_GENERAL_exist_directory() {

  test_suite_start "GENERAL exist_directory"

  # Paths relative to TEST_TMP_DIR
  local dir1="$TEST_TMP_DIR/dummy_dir_1"
  local non_existent_dir="$TEST_TMP_DIR/non_existent_dir"

  # Test case 1: Directory exists
  test_case_start "exist_directory - exists"
  assert_success "exist_directory $dir1" "Should succeed when directory exists"
  test_case_end

  # Test case 2: Directory does not exist
  test_case_start "exist_directory - does not exist"
  local expected_output=$"Error: directory '$non_existent_dir' not found."
  assert_output "$expected_output" "exist_directory $non_existent_dir" "Should output error for missing directory"
  assert_failure 1 "exist_directory $non_existent_dir" "Should exit with status 1 for missing directory"

  test_suite_end "GENERAL exist_directory"

}

# -----------------------------------------------------------------------------
# test_GENERAL_display_banner() tests the display_banner function
#
test_GENERAL_display_banner() {

  test_suite_start "GENERAL display_banner"

  # This test relies on the dummy config.json setup in setup_suite
  test_case_start "display_banner - default output"
  # Construct the expected output based on the DUMMY_CONFIG_CONTENT
  # This requires careful formatting matching the script's printf
  local expected_banner_output
  expected_banner_output=$'\n'
  expected_banner_output+=" |"$'\n'
  expected_banner_output+=" |  A bash template (BaT) to ease argument parsing and management"$'\n'
  expected_banner_output+=" |    1.2.0"$'\n'
  expected_banner_output+=" |"$'\n'
  expected_banner_output+=" |  Usage:"$'\n'
  expected_banner_output+=" |    bash_template.sh -a alpha -b bravo [-c charlie] -d delta"$'\n'
  expected_banner_output+=" |"$'\n'
  # The argument lines require calculating the max width
  # Short/long forms in config: "-a", "--alpha" ; "-b", "--bravo" ; "-c", "--charlie" ; "-d", "--delta"
  # Combined lengths: "-a--alpha" (9), "-b--bravo" (8), "-c--charlie" (11), "-d--delta" (8)
  # Max length is 11. Script adds 6 to max_col. So max_col = 11 + 6 = 17.
  # printf format is "%-${max_col}s" -> "%-17s"
  expected_banner_output+=" |  -a, --alpha    alpha (something descriptive)"$'\n'
  expected_banner_output+=" |  -b, --bravo    bravo (something descriptive)"$'\n'
  expected_banner_output+=" |  -c, --charlie  charlie (this is optional)"$'\n'
  expected_banner_output+=" |  -d, --delta    delta (something descriptive)"$'\n'
  expected_banner_output+=" |"

  assert_output "$expected_banner_output" "display_banner" "Check banner format and content"

  test_suite_end "GENERAL display_banner"

}

# -----------------------------------------------------------------------------
# run_tests() runs all the tests
#
run_tests() {

  setup_suite

  # Run tests for the ARGS library
  test_ARGS_jq_functions
  test_ARGS_scan_for_args
  test_ARGS_get_config_arg_value
  test_ARGS_check_for_args_completeness

  # Run tests for the GENERAL library
  test_GENERAL_quit # Test quit first as others depend on its functionality indirectly
  test_GENERAL_check_program_dependencies
  test_GENERAL_check_file_dependencies
  test_GENERAL_exist_directory

  test_GENERAL_display_banner # Depends on ARGS functions, which depend on jq program

  log "+---- Test Summary"
  log "|"
  log "| ✅ Successful Tests: $((TOTAL_TESTS - FAILED_TESTS))"
  log "| ❌ Failed Tests: $FAILED_TESTS"

  if [[ $FAILED_TESTS -eq 0 ]]; then
    log "| All $TOTAL_TESTS tests passed!"
    log "|"
    log "+----"
    return 0
  else
    log "| Some tests failed!"
    log "|"
    log "+----"
    return 1
  fi

}

# Run the tests already!
run_tests
