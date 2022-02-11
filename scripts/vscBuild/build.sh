#!/bin/bash

rm -r ./_build
mkdir ./_build

cp -r ./components ./_build
cp -r ./manifest ./_build
cp -r ./source ./_build
