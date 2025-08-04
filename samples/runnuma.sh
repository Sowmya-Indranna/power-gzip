#!/bin/bash

# filename and number of instances
echo $1 $2

C=$2

rm -f *.nx.gunzip

for S in `seq 1 $C`
do
    FN=$S.$1
    echo $FN
    rm -f $FN

    # create the unique file
    cp $1 $FN

    # FS cache warmup
    cat $FN > /dev/null
done

# Get NUMA nodes that actually have CPUs
NODES=$(numactl --hardware | grep "node [0-9]" | grep cpus: | grep -v "cpus:$" | awk '{print $2}')

for S in `seq 1 $C`
do
    FN=$S.$1
    for node in $NODES
    do
        if [ "$node" -lt "16" ]; then
            echo "Running on NUMA node $node: ./gunzip_nx_test $FN"
            numactl -N $node ./gunzip_nx_test $FN  &
        fi
    done
done

wait
