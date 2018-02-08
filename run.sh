#!/bin/bash
set -x

/usr/sbin/nginx 

export USER=git
exec gosu $USER /home/git/gogs/gogs web