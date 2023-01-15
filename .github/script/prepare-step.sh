#!/usr/bin/env sh

workflow_file=$1

echo "Set committer details"
git config user.name github-actions
git config user.email github-actions@github.com

git checkout main
cp ./.github/changes/"${workflow_file}" ./.github/workflows/"${workflow_file}"
git add ./.github/workflows/"${workflow_file}"

git commit -m "Add ${workflow_file} workflow"
git push --set-upstream origin main
