#!/bin/sh

read -d ' ' name
read -d ' ' url
read -d ' ' destination_path
destination_path=$destination_path
curl --create-dirs -o $destination_path/$name $url
echo $name $destination_path $APPLICATIONS_PATH
