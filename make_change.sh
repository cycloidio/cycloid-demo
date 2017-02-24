#!/bin/bash

LAST_VERSION=$(git describe --abbrev=0 --tags)

#replace . with space so can split into an array
VERSION_BITS=(${LAST_VERSION//./ })

#get number parts and increase last one by 1
VNUM1=${VERSION_BITS[0]}
VNUM2=${VERSION_BITS[1]}
VNUM3=${VERSION_BITS[2]}
VNUM3=$((VNUM3+1))

#create new tag
NEW_TAG="$VNUM1.$VNUM2.$VNUM3"

#If orig color
echo "Make change"
if [ $(grep 0f9797 ./imgs/main.css -c) = 0 ]; then
  echo "revert to 0f9797"
  sed -i 's/38407c/0f9797/g' imgs/main.css
  echo $NEW_TAG
else
  echo "change to 38407c"
  sed -i 's/0f9797/38407c/g' imgs/main.css
  echo $NEW_TAG
fi

echo "git commit"
git add imgs/main.css
git commit -m "make a change for version $NEW_TAG"

echo "git push"
git push

echo "git tag"
git tag $NEW_TAG
git push origin $NEW_TAG
