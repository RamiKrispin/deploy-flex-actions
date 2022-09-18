#!/bin/bash

echo "Rendering the dashboard..."

Rscript -e "rmarkdown::render_site()"

# Fix github issue
git config --global --add safe.directory /__w/deploy-flex-actions/deploy-flex-actions

if [[ "$(git status --porcelain)" != "" ]]; then
    git config --global user.name $1
    git config --global user.email $2
    git add *
    git commit -m "Auto update dashboard"
    git push
fi
