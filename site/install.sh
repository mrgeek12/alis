#!/usr/bin/env bash
git clone -b master git@github.com:mrgeek12/alis.git
cd alis
git config --local user.email "mr.geek1@protonmail.com"
git config --local user.name "mrgeek12"

git clone -b gh-pages git@github.com:mrgeek12/alis.git deploy/
cd deploy
git config --local user.email "mr.geek1@protonmail.com"
git config --local user.name "mrgeek12"
