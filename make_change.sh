#!/bin/bash

#If orig color
echo "Make change"
if [ $(grep 0f9797 ./imgs/main.css -c) = 0 ]; then
  comment="revert to light blue background"
  sed -i 's/38407c/0f9797/g' imgs/main.css
else
  comment="change to dark blue background"
  sed -i 's/0f9797/38407c/g' imgs/main.css
fi

echo $comment

echo "git config"
git config --global user.name "Cycloid"
git config --global user.email contact@cycloid.io

echo "git commit/push"
git add imgs/main.css
git commit -m "make a change : $comment"

# Increment version number
source version
# We can increment major/minor/patch (0.0.0)
bumpversion --current-version $version  patch version --commit --tag
source version

echo "git push tag"
git push origin master
git push origin v$version
