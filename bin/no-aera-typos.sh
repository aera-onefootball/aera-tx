#!/bin/bash

if grep \
    -R \
    --exclude-dir={.git,bin} \
    --exclude=.pre-commit-config.yaml \
    "AERA" .; then
    exit 1
else
    echo "no typo found"
fi


if grep \
    -R \
    --exclude-dir={.git,bin} \
    --exclude=.pre-commit-config.yaml \
    "Hattricks" .; then
    exit 1
else
    echo "no typo found"
fi
