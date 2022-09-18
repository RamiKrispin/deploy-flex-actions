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

if [[ "$(git status --porcelain)" != "" ]]; then
    git config --global user.name 'RamiKrispin'
    git config --global user.email 'ramkrisp@umich.edu'
    git add *
    git commit -m "Auto update dashboard"
    git push
fi
