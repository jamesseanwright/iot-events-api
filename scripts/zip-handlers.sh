#!/usr/bin/env bash

get_handler_archive_filename() {
  handler_path=$1
  handler_name=$(echo $handler_path | sed -r "s/^handlers\/(.*)\/index.js$/\1/g")
  echo "deployment/$handler_name.zip"
}

mkdir -p deployment
rm -rf deployment/*

handlers=( $(find handlers -name *.js) )
echo $handlers

for handler in "${handlers[@]}"
do
  echo "Archiving $handler..."
  zip -j $(get_handler_archive_filename $handler) $handler
done

echo "Done!"
