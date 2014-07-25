#!/bin/bash

#mount -t hugetlbfs none /mnt/huge
#echo 128 > /proc/sys/vm/nr_hugepages
. ./floatfunc

if [ -z "$1" -o -z "$2" ]; then
    echo "usage: mlptest.sh <corun> <mlp>"
    exit 1
fi

corun=$1
mlp=$2

for l in `seq 1 $mlp`; do 
    for c in `seq 1 $corun`; do
	./latency-mlp -c $c -l $l -i 2000000000 >& /dev/null &
    done
    sleep 0.5
    ./latency-mlp -c 0 -l $l -i 100
    killall latency-mlp
done  > /tmp/test.txt
BWS=`grep bandwidth /tmp/test.txt | awk '{ print $2 }'`

for b in $BWS; do
    echo $b $(float_eval "$b * ( $corun + 1)")
done
