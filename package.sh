#! /bin/bash

echo installing requirements..
pip install -r requirements.txt --target ./package

echo copying python files..
cp *.py ./package

echo creating zip archive..
cd package && zip -r9 ../cloudwatch-to-slack-`date +%Y%m%d%H%M`.zip .