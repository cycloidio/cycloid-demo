#!/bin/bash

#If orig color
echo "Make change"
if [ $(grep 0f9797 ./imgs/main.css -c) = 0 ]; then
  comment="revert to 0f9797"
  sed -i 's/38407c/0f9797/g' imgs/main.css
else
  comment="change to 38407c"
  sed -i 's/0f9797/38407c/g' imgs/main.css
fi
echo $comment

echo "git commit"
git add imgs/main.css
git commit -m "make a change : $comment"

# Increment version number
source changelog
# We can increment major/minor/patch (0.0.0)
bumpversion --current-version $version  patch changelog --commit --tag

echo "git push"
git push --tags
