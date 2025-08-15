#!/bin/bash

set_template_repository() {
  local repo_name="$1"
  local is_template="$2"
  local owner="$3"
  local token="$4"

  if [ -z "$repo_name" ] || [ -z "$is_template" ] || [ -z "$owner" ] || [ -z "$token" ]; then
    echo "Error: Missing required parameters"
    echo "error-message=Missing required parameters: repo-name, is-template, owner, and token must be provided." >> "$GITHUB_OUTPUT"
    echo "result=failure" >> "$GITHUB_OUTPUT"
    return
  fi

  # Convert is_template to lowercase for API compatibility
  is_template=$(echo "$is_template" | tr '[:upper:]' '[:lower:]')

  # Validate is_template
  if [ "$is_template" != "true" ] && [ "$is_template" != "false" ]; then
    echo "Error: Invalid is-template value '$is_template'. Must be 'true' or 'false'."
    echo "error-message=Invalid is-template value '$is_template'. Must be 'true' or 'false'." >> "$GITHUB_OUTPUT"
    echo "result=failure" >> "$GITHUB_OUTPUT"
    return
  fi

  echo "Attempting to set repository '$repo_name' to template status '$is_template' for owner '$owner'"

  # Use MOCK_API if set, otherwise default to GitHub API
  local api_base_url="${MOCK_API:-https://api.github.com}"

  # Set repository template status using GitHub API
  RESPONSE=$(curl -s -L \
    -w "%{http_code}" \
    -X PATCH \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer $token" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    -H "Content-Type: application/json" \
    -o response_body.json \
    "$api_base_url/repos/$owner/$repo_name" \
    -d "{\"is_template\":$is_template}")

  if [ "$RESPONSE" -eq 200 ]; then
    echo "Successfully set $repo_name to template status $is_template"
    echo "result=success" >> "$GITHUB_OUTPUT"
  else
    echo "Error: Failed to set $repo_name to template status $is_template. HTTP Status: $RESPONSE"
    echo "error-message=Failed to set repository to template status $is_template. HTTP Status: $RESPONSE" >> "$GITHUB_OUTPUT"
    echo "result=failure" >> "$GITHUB_OUTPUT"
  fi

  # Clean up temporary file
  rm -f response_body.json
}
