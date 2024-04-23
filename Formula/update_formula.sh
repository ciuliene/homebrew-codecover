#!/bin/bash

USER=$1
REPO_SUFFIX="homebrew"
REPO=$2
TAG=$3

# Get the URL of the release
url="https://github.com/$USER/$REPO_SUFFIX-$REPO/releases/download/$TAG/${REPO}-v$TAG.tar.gz"

# Calculate SHA256
sha256=$(echo $(curl -sL "$url" | sha256sum) | sed 's/[[:space:]]*-$//')

row4="url \"https://github.com/$USER/$REPO_SUFFIX-$REPO/releases/download/${TAG}/${REPO}-v${TAG}.tar.gz\""
row5="sha256 \"$sha256\""
row13="assert_match \"v${TAG}\", shell_output(\"#{bin}/${REPO} --version\")"

# Replace values into the formula
sed -i "4s/.*/$(echo "    $row4" | sed -e 's/[\/&]/\\&/g')/" Formula/$REPO.rb
sed -i "5s/.*/$(echo "    $row5" | sed -e 's/[\/&]/\\&/g')/" Formula/$REPO.rb
sed -i "13s/.*/$(echo "        $row13" | sed -e 's/[\/&]/\\&/g')/" Formula/$REPO.rb
