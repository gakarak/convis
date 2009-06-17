#!/bin/bash

dstd="backup"
bkflst="transporter.fig transporter.m"

############
for ii in $bkflst
do
    dst="$dstd/$ii"
    echo -n "Copy [$ii] to [$dst] ..."
    cp -f $ii $dst
    echo "... [Ok]"
done

