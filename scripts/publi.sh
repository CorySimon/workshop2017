#!/bin/sh

DIR=$(dirname "$0")

cd $DIR/..

if [[ $(git status -s) ]]
then
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
fi

echo "Deleting old publication"
rm -rf public
mkdir public
git worktree prune
rm -rf .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public origin/gh-pages

echo "Removing existing files"
rm -rf public/*

echo "Generating site"
hugo
mkdir public/2017
shopt -s extglob
mv ./public/!(2017|.git) ./public/2017/
cp CNAME ./public/

echo "Updating gh-pages branch"
cd public && git add --all && git commit -m "Publishing to gh-pages (publi.sh)"

read -erp "Push gh-pages to origin? (y/n): " doPushToRemote

if [[ "$doPushToRemote" == "y" ]]
then
    echo "Pushing to remote..."
    git push origin gh-pages
fi
