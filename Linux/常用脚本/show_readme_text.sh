#!/usr/bin/env bash
readme="readme.txt"
if [ -f $readme ];then
	cat $readme
else echo "file $readme not found"
fi