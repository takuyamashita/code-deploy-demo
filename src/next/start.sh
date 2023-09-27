#!/bin/bash

. ~/.nvm/nvm.sh

cd /app

npm install
npm run build

sudo systemctl daemon-reload
sudo systemctl restart app