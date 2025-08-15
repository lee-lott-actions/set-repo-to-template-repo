#!/usr/bin/env bats

# Load the Bash script
load ../action.sh

# Mock the curl command to simulate API responses
mock_curl() {
  local http_code=$1
  local response_file=$2
  echo "$http_code"
  cat "$response_file" > response_body.json
}

# Setup function to run before each test
setup() {
  export GITHUB_OUTPUT=$(mktemp)
}

# Teardown function to clean up after each test
teardown() {
  rm -f response_body.json "$GITHUB_OUTPUT" mock_response.json
}

@test "set_template_repository succeeds with HTTP 200 for is_template true" {
  echo '{"name": "test-repo", "is_template": true}' > mock_response.json
  curl() { mock_curl "200" mock_response.json; }
  export -f curl

  run set_template_repository "test-repo" "true" "test-owner" "fake-token"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=success" ]
}

@test "set_template_repository succeeds with HTTP 200 for is_template false" {
  echo '{"name": "test-repo", "is_template": false}' > mock_response.json
  curl() { mock_curl "200" mock_response.json; }
  export -f curl

  run set_template_repository "test-repo" "false" "test-owner" "fake-token"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=success" ]
}

@test "set_template_repository fails with HTTP 404 (repository not found)" {
  echo '{"message": "Not Found"}' > mock_response.json
  curl() { mock_curl "404" mock_response.json; }
  export -f curl

  run set_template_repository "test-repo" "true" "test-owner" "fake-token"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Failed to set repository to template status true. HTTP Status: 404" ]
}

@test "set_template_repository fails with invalid is_template value" {
  run set_template_repository "test-repo" "invalid-value" "test-owner" "fake-token"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Invalid is-template value 'invalid-value'. Must be 'true' or 'false'." ]
}

@test "set_template_repository fails with empty repo_name" {
  run set_template_repository "" "true" "test-owner" "fake-token"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: repo-name, is-template, owner, and token must be provided." ]
}

@test "set_template_repository fails with empty is_template" {
  run set_template_repository "test-repo" "" "test-owner" "fake-token"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: repo-name, is-template, owner, and token must be provided." ]
}

@test "set_template_repository fails with empty owner" {
  run set_template_repository "test-repo" "true" "" "fake-token"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: repo-name, is-template, owner, and token must be provided." ]
}

@test "set_template_repository fails with empty token" {
  run set_template_repository "test-repo" "true" "test-owner" ""

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" = "result=failure" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" = "error-message=Missing required parameters: repo-name, is-template, owner, and token must be provided." ]
}
