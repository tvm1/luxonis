#!/bin/sh
set -e

/etc/init.d/postgresql start
python3 app/main.py