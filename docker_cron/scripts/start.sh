#!/bin/bash

printenv | sed 's/^\(.*\)$/export \1/g' > /root/scripts/.env.sh
chmod +x /root/scripts/.env.sh

