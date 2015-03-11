#!/bin/sh

# 创建用户
groupadd -f -g 1000 -r webuser
useradd -d /home/webuser -g 1000 -u 1000 -G webuser webuser

mkdir -p /home/webuser/.ssh
mkdir -p /home/webuser/www