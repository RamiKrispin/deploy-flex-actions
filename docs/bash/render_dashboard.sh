#!/bin/bash

echo "Rendering the dashboard..."
if [[ "$1" = ""  || "$2" = "" ]] ; then
    echo "The git user.name and/or user.email are missing"
    exit 0
else
    echo "Git user.name is $1"
    echo "Git user.email is $2"
fi


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