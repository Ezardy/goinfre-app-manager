#!/bin/sh

read -d ' ' name
read -d ' ' src
read -d ' ' dst
mv $src $dst
echo $name $src $dst
