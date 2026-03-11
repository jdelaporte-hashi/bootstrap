#!/bin/bash
while [ $# -gt 0 ]
do
    clustername="$1"
    echo $clustername
    shift
done