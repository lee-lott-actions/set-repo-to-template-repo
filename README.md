# Set Repository Template Status Action

This GitHub Action sets a repository template repository status using the GitHub API. It returns a result indicating whether the repository was created successfully (`success` for HTTP 201, `failure` otherwise) and an error message with details if the creation fails.

## Features
- Set repository template status via the GitHub API.
- Outputs a result (`success` or `failure`) and an error message for easy integration into workflows.
- Requires a GitHub token with `repo` scope for repository creation.

## Inputs
| Name              | Description                                      | Required | Default |
|-------------------|--------------------------------------------------|----------|---------|
| `repo-name`       | The name of the new repository to create.        | Yes      | N/A     |
| `is-template`     | The template status of the repository ("true" or "false")      | Yes      | N/A     |
| `owner`           | The owner of the template and new repository (user or organization). | Yes | N/A |
| `token`           | GitHub token with repository write access.       | Yes      | N/A     |

## Outputs
| Name           | Description                                           |
|----------------|-------------------------------------------------------|
| `result`       | Result of the repository creation (`success` for HTTP 201, `failure` otherwise). |
| `error-message`| Error message if the repository creation fails.       |

## Usage
1. **Add the Action to Your Workflow**:
   Create or update a workflow file (e.g., `.github/workflows/set-repo-template-status.yml`) in your repository.

2. **Reference the Action**:
   Use the action by referencing the repository and version (e.g., `v1`), or the local path if stored in the same repository.

3. **Example Workflow**:
   ```yaml
   name: Set Repository Template Status
   on:
     push:
       branches:
         - main
   jobs:
     set-template-repo:
       runs-on: ubuntu-latest
       steps:
         - name: Set Template Repository
           id: set-template-repo
           uses: lee-lott-actions/set-repo-template-status@v1
           with:
             repo-name: 'test-repo'
             is-template: true
             owner: ${{ github.repository_owner }}
             token: ${{ secrets.GITHUB_TOKEN }}
         - name: Check Result
           run: |
             if [[ "${{ steps.set-template-repo.outputs.result }}" == "success" ]]; then
               echo "Repository template status successfully updated."
             else
               echo "${{ steps.set-template-repo.outputs.error-message }}"
               exit 1
             fi
