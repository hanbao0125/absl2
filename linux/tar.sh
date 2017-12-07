#!/bin/sh

#genearte archive file name

year=`date | awk '{printf "%s",$6}'`
month=`date | awk '{printf "%s",$2}'`
day=`date | awk '{printf "%s",$3}'`
suf=$day$month$year

echo $suf

backname="src"$suf".tar.gz"

echo $backname

#create archive file

tar -cvzf "/home/liujiang/document/"$backname /home/src/
