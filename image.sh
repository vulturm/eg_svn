#!/bin/bash
systemctl stop svnserve
docker rmi svn-ssh
docker build -t svn-ssh:1.1 .
systemctl start svnserve
