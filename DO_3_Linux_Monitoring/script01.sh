#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "Incorrect number of parameters"
  exit 1
fi

if [[ $1 =~ ^[0-9]+$ ]]; then
  echo "Invalid input"
else
  echo "$1"
fi