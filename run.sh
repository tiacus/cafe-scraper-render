#!/bin/bash
set -e

echo "--- Starting Scraper Cron Job ---"

# 1. Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt

# 2. Run the scraper script
echo "Running scrape_collabo_cafe.py..."
python scrape_collabo_cafe.py

# 3. Check for changes and push to GitHub
echo "Checking for changes in notified_urls.txt..."

# git status --porcelain will be empty if there are no changes
if [[ -z $(git status --porcelain notified_urls.txt) ]]; then
  echo "No changes detected. Exiting."
else
  echo "Changes detected in notified_urls.txt. Pushing to GitHub..."

  # Configure Git
  # These environment variables must be set in Render
  git config --global user.name "${GIT_USER_NAME}"
  git config --global user.email "${GIT_USER_EMAIL}"

  # Add the file, commit, and push
  # The GIT_REPO_URL should be just "github.com/YourUser/YourRepo.git"
  # The GITHUB_TOKEN is a Personal Access Token with repo scope
  git add notified_urls.txt
  git commit -m "Update notified_urls.txt [Render Cron]"
  
  # Create a remote URL with the token for authentication
  REMOTE_URL="https://_:${GITHUB_TOKEN}@${GIT_REPO_URL}"
  
  git push "${REMOTE_URL}" HEAD:main # Pushing to the main branch
  
  echo "Successfully pushed changes to GitHub."
fi

echo "--- Scraper Cron Job Finished ---"
